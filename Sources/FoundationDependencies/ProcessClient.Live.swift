import Foundation

extension ProcessClient {
    public static var live: Self {
        Self(
            runWithOutput: { executable, arguments, outputDestination in
                try await runInternal(executable: executable, arguments: arguments, outputDestination: outputDestination)
            }
        )
    }
    
    private static func runInternal(
        executable: Executable,
        arguments: Arguments,
        outputDestination: OutputDestination
    ) async throws -> CollectedResult {
        let process = Process()
        let stderrPipe = Pipe()
        process.standardError = stderrPipe
        
        @Sendable
        func readAll(_ handle: FileHandle) async throws -> Data {
            var buffer = [UInt8]()
            buffer.reserveCapacity(16 * 1024)
            for try await byte in handle.bytes {
                buffer.append(byte)
            }
            return Data(buffer)
        }
        
        // Set up executable and arguments
        switch executable {
        case let .name(name):
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = [name] + arguments
        case let .path(path):
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = arguments
        }
        
        // Handle stdout based on output destination
        switch outputDestination {
        case .stdout:
            let stdoutPipe = Pipe()
            process.standardOutput = stdoutPipe
            
            try process.run()
            
            // Start reading immediately to avoid backpressure deadlocks
            async let outData: Data = readAll(stdoutPipe.fileHandleForReading)
            async let errData: Data = readAll(stderrPipe.fileHandleForReading)
            
            // Await termination without blocking a thread
            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                process.terminationHandler = { _ in cont.resume() }
            }
            
            // IMPORTANT: only now await the readers (do NOT close the FDs before this)
            let (o, e) = try await (outData, errData)
            
            let out = o.isEmpty ? nil : String(data: o, encoding: .utf8) ?? String(decoding: o, as: UTF8.self)
            let err = e.isEmpty ? nil : String(data: e, encoding: .utf8) ?? String(decoding: e, as: UTF8.self)
            
            if process.terminationStatus != 0 {
                struct SubprocessError: LocalizedError {
                    let code: Int32
                    let stderr: String?
                    var errorDescription: String? { "Process exited with code \(code)" + (stderr.map { ": \($0)" } ?? "") }
                }
                throw SubprocessError(code: process.terminationStatus, stderr: err)
            }
            
            return CollectedResult(standardOutput: out, standardError: err)
            
        case .file(let outputURL):
            // Ensure directory
            try FileManager.default.createDirectory(
                at: outputURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            // Make sure we’ll write a fresh file. This avoids any “no-overwrite” semantics.
            _ = try? FileManager.default.removeItem(at: outputURL)
            FileManager.default.createFile(atPath: outputURL.path, contents: nil, attributes: nil)

            // Open for writing (no atomic, no withoutOverwriting)
            let outputFile = try FileHandle(forWritingTo: outputURL)
            process.standardOutput = outputFile

            try process.run()

            // Read only stderr; stdout goes straight to file.
            async let errData: Data = readAll(stderrPipe.fileHandleForReading)

            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                process.terminationHandler = { _ in cont.resume() }
            }

            // Close our write handle after process exits
            try? outputFile.close()

            let e = try await errData
            let err = e.isEmpty ? nil : String(data: e, encoding: .utf8) ?? String(decoding: e, as: UTF8.self)

            if process.terminationStatus != 0 {
                struct SubprocessError: LocalizedError {
                    let code: Int32
                    let stderr: String?
                    var errorDescription: String? { "Process exited with code \(code)" + (stderr.map { ": \($0)" } ?? "") }
                }
                throw SubprocessError(code: process.terminationStatus, stderr: err)
            }

            return CollectedResult(standardOutput: nil, standardError: err)
        }
    }
}
