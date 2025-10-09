import Foundation

public struct ProcessClient {
    public enum Executable {
        case name(String)
        case path(String)
    }
    
    public enum OutputDestination {
        case stdout
        case file(URL)
    }
    
    public struct CollectedResult {
        public var standardOutput: String?
        public var standardError: String?
        
        public init(
            standardOutput: String? = nil,
            standardError: String? = nil
        ) {
            self.standardOutput = standardOutput
            self.standardError = standardError
        }
    }
    
    public typealias Arguments = [String]
    
    public var runWithOutput: (Executable, Arguments, OutputDestination) async throws -> CollectedResult
    
    public init(
        runWithOutput: @escaping (Executable, Arguments, OutputDestination) async throws -> CollectedResult
    ) {
        self.runWithOutput = runWithOutput
    }
    
    @discardableResult
    public func run(
        _ executable: Executable,
        arguments: Arguments,
        outputTo destination: OutputDestination = .stdout
    ) async throws -> CollectedResult {
        try await runWithOutput(executable, arguments, destination)
    }
}
