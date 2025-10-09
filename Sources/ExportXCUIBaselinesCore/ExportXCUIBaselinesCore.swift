import Foundation
import FoundationDependencies
import LoggingClient

public enum ExportXCUIBaselinesCore {
    public static func run(
        xcresult: String,
        fileManager: FoundationFileManager,
        uuidGen: UUIDGenerate,
        createUrlClient: FoundationURLClient.Create,
        processClient: ProcessClient,
        createLogging: LoggingClient.Create,
        dataClient: FoundationDataClient,
        stringClient: StringClient
    ) async throws {
        let subsystem = "ios-xcuitest-baseline-exporter"
        let tempDirId = uuidGen()
        
        let fileManagerLogger = createLogging(
            subsystem: subsystem,
            category: "FileManager"
        )
        
        let commonLogger = createLogging(
            subsystem: subsystem,
            category: "common"
        )
        
        let tempDir = fileManager
            .temporaryDirectory()
            .appendingPathComponent(tempDirId.uuidString)
        
        let attachmentsInTempDir = tempDir.appending(component: "attachments")
        
        defer {
            try? fileManager.removeItem(at: tempDir)
        }
        
        do {
            try fileManager.createDirectory(
                at: attachmentsInTempDir,
                withIntermediateDirectories: true
            )
        } catch {
            fileManagerLogger.error("\(error.localizedDescription)")
            return
        }
        
        guard fileManager.fileExists(atPath: xcresult) else {
            fileManagerLogger.error("Unable to locate '\(xcresult)'")
            return
        }
        
        let xcResultPath: String
        
        switch xcresult.hasSuffix(".xcresult") {
        case true:
            xcResultPath = xcresult
        case false:
            guard let latestXCResultPath = try Self
                .xcResultFolderFromBuildFolderOrDerivedData(
                    URL(fileURLWithPath: xcresult),
                    fileManager: fileManager,
                    createUrlClient: createUrlClient
                ) else {
                fileManagerLogger.error("Unable to locate .xcresult folder using: '\(xcresult)'")
                return
            }
            // Since .xcresult folder may contain spaces, we don't want to
            // url encode them.
            xcResultPath = latestXCResultPath.path(percentEncoded: false)
        }
        
        fileManagerLogger.info("Resolved '.xcresult' path as: \(xcResultPath)")
        
        let xcResultURL = URL(fileURLWithPath: xcResultPath)
        let xcResultSourceDir: URL
        
        xcResultSourceDir = xcResultURL
        
        let xcResultToolLogger = createLogging(
            subsystem: subsystem,
            category: "xcresulttool"
        )
        
        // Since `xcresulttool export attachments` is supported only from Xcode 15.3+,
        // we need to provide fallback to legacy API.
        let isExportAttachmentsAvailable = try await Self.isExportAttachmentsAvailable(
            tempDir: tempDir,
            processClient: processClient,
            fileManager: fileManager,
            stringClient: stringClient
        )
        
        xcResultToolLogger.info("isExportAttachmentsAvailable: \(isExportAttachmentsAvailable)")
        
        if !isExportAttachmentsAvailable {
            // Pass "--legacy" if testing has to be performed on Xcode 16+
            let legacyArg: [String] = []
            
            xcResultToolLogger.info("Getting graph...")
            
            // Create a temporary file for the large graph output to avoid stdout buffer issues.
            let graphFile = tempDir.appending(component: "graph")
            
            try await processClient.run(
                .name("xcrun"),
                arguments: [
                    "xcresulttool",
                    "graph",
                    "--path", xcResultSourceDir.path(percentEncoded: false),
                ] + legacyArg,
                outputTo: .file(graphFile)
            )
            
            let graphOutput = try stringClient.string(
                contentsOf: graphFile,
                encoding: .utf8
            )
            try fileManager.removeItem(at: graphFile)
            
            let summaryIDs = Self.extractTestSummaryIDs(from: graphOutput)

            let decoder = JSONDecoder()
            
            var legacyEntries: [Legacy.Entry] = []
            
            // Extract attachments for every summary to temporary attachments directory.
            for (summaryCounter, summaryID) in zip(1..., summaryIDs) {
                xcResultToolLogger.info(
                    "Processing summary \(summaryCounter)/\(summaryIDs.count): \(summaryID)"
                )

                // Create a temporary file for the large JSON output to avoid stdout buffer issues.
                let tempSummaryFile = tempDir.appending(component: "summary_\(summaryCounter).json")
                
                let summaryDataResult = try await processClient.run(
                    .name("xcrun"),
                    arguments: [
                        "xcresulttool",
                        "get",
                        "--id", summaryID,
                        "--path", xcResultSourceDir.path(percentEncoded: false),
                        "--format", "json",
                    ] + legacyArg,
                    outputTo: .file(tempSummaryFile)
                )
                
                if let summaryError = summaryDataResult.standardError {
                    xcResultToolLogger.error(summaryError)
                    return
                }
                
                // Read the JSON data from the file instead of stdout
                let summaryData = try dataClient.dataWithContentsOf(url: tempSummaryFile)

                let legacyEntry = try decoder.decode(Legacy.Entry.self, from: summaryData)
                defer {
                    legacyEntries.append(legacyEntry)
                }
                // Clean up the temporary summary file
                try fileManager.removeItem(at: tempSummaryFile)
                
                for attachment in legacyEntry.attachments {
                    // We need to strip down index and uuid from exported filename so
                    // that we could reuse same mappings processing functions, used for
                    // regular 'manifest.json' flow (BaselineProcessor.baselineAndAutomationManifestMappings).
                    let exportFile = BaselineProcessor.stripIndexUUID(
                        from: attachmentsInTempDir.appending(components: attachment.suggestedHumanReadableName)
                    )
                    
                    try await processClient.run(
                        .name("xcrun"),
                        arguments: [
                            "xcresulttool",
                            "export",
                            "--path", xcResultSourceDir.path(percentEncoded: false),
                            "--id", attachment.payloadReferenceID,
                            "--type", "file",
                            "--output-path", exportFile.path(percentEncoded: false),
                        ] + legacyArg
                    )
                }
            }
            
            let entries = legacyEntries.map(Entry.init)
            let mappings = try BaselineProcessor.baselineAndAutomationManifestMappings(
                entries: entries,
                nameRegex: BaselineProcessor.regExp()
            )
            let copiedCount = try BaselineProcessor.processManifest(
                mappings: mappings,
                in: attachmentsInTempDir.path(percentEncoded: false),
                fileManager: fileManager,
                fileManagerLogger: fileManagerLogger,
                overridingAutomationBaselineDirectory: nil
            )
            
            if copiedCount == 0 {
                commonLogger.warning(
                    "No baseline attachments found in '\(xcResultPath)'."
                )
            } else {
                commonLogger.info(
                    "Done. Saved \(copiedCount) baseline file(s) to their target directories."
                )
            }
        } else {
            let exportAttachmentResultFile = tempDir.appending(component: "exportAttachmentResult")
            try await processClient
                .run(
                    .name("xcrun"),
                    arguments: [
                        "xcresulttool", "export", "attachments",
                        "--path", xcResultSourceDir.path(percentEncoded: false),
                        "--output-path", attachmentsInTempDir.path(percentEncoded: false)
                    ],
                    outputTo: .file(exportAttachmentResultFile)
                )
            try runManifestFlow(
                attachmentsInTempDir: attachmentsInTempDir,
                dataClient: dataClient,
                xcResultToolLogger: xcResultToolLogger,
                fileManager: fileManager,
                fileManagerLogger: fileManagerLogger,
                commonLogger: commonLogger
            )
        }
    }
    
    static func isExportAttachmentsAvailable(
        tempDir: URL,
        processClient: ProcessClient,
        fileManager: FoundationFileManager,
        stringClient: StringClient
    ) async throws -> Bool {
        let exportAttachmentsCheckFile = tempDir.appending(component: "export-attachments-check")
       
        try await processClient.run(
            .name("xcrun"),
            arguments: ["xcresulttool", "export", "--help"],
            outputTo: .file(exportAttachmentsCheckFile)
        )
        
        let isExportAttachmentsAvailable = try stringClient.string(
            contentsOf: exportAttachmentsCheckFile,
            encoding: .utf8
        )
        .contains("attachments")
        try fileManager.removeItem(at: exportAttachmentsCheckFile)
        return isExportAttachmentsAvailable
    }
    
    public static func runManifestFlow(
        attachmentsInTempDir: URL,
        dataClient: FoundationDataClient,
        xcResultToolLogger: LoggingClient,
        fileManager: FoundationFileManager,
        fileManagerLogger: LoggingClient,
        commonLogger: LoggingClient
    ) throws {
        let manifest = attachmentsInTempDir.appending(component: "manifest.json")
        
        guard fileManager.fileExists(atPath: manifest.path(percentEncoded: false)) else {
            fileManagerLogger.error("No manifest.json found at '\(manifest.path(percentEncoded: false))'.")
            return
        }
    
        let baselineMappings = try BaselineProcessor.baselineAndAutomationManifestMappings(
            entries: BaselineProcessor.manifestEntries(
                manifest.path(percentEncoded: false),
                dataClient: dataClient
            ),
            nameRegex: BaselineProcessor.regExp()
        )
        
        let copiedCount = try BaselineProcessor.processManifest(
            mappings: baselineMappings,
            in: attachmentsInTempDir.path(),
            fileManager: fileManager,
            fileManagerLogger: fileManagerLogger,
            overridingAutomationBaselineDirectory: nil
        )
        
        if copiedCount == 0 {
            commonLogger.warning("No baseline attachments found in manifest.")
        } else {
            commonLogger.info(
                "Done. Saved \(copiedCount) baseline file(s) to their target directories"
            )
        }
    }
    
    public static func xcResultFolderFromBuildFolderOrDerivedData(
        _ buildFolderOrDerivedData: URL,
        fileManager: FoundationFileManager,
        createUrlClient: FoundationURLClient.Create
    ) throws -> URL? {
        let isBuildFolder = buildFolderOrDerivedData.lastPathComponent.lowercased() == "build"

        // Resolve "Logs/Test" folder from app's derived data folder or nested Build folder in derived data.
        let logsTestFolder =
        (
            isBuildFolder
            ? buildFolderOrDerivedData.deletingLastPathComponent()
            : buildFolderOrDerivedData
        )
        .appending(component: "Logs/Test")
    
        // Enumerate .xcresult folders and pickup latest one.
        return try fileManager
            .contentsOfDirectory(
                at: logsTestFolder,
                includingPropertiesForKeys: [.contentModificationDateKey]
            )
            .filter { $0.pathExtension == "xcresult" }
            .sorted {
                let aDate = try? createUrlClient(url: $0)
                    .resourceValues(
                        forKeys: [.contentModificationDateKey]
                    )
                    .contentModificationDate ?? .distantPast
                let bDate = try? createUrlClient(url: $1)
                    .resourceValues(
                        forKeys: [.contentModificationDateKey]
                    )
                    .contentModificationDate ?? .distantPast
                return aDate ?? .distantPast > bDate ?? .distantPast
            }
            .first
    }
}

extension ExportXCUIBaselinesCore {
    /// Parses a `.xcresulttool formatDescription` string and extracts all **ActionTestSummary Ids**.
    public static func extractTestSummaryIDs(from text: String) -> [String] {
        // Regex explanation:
        // - Look for the literal "ActionTestSummary"
        // - Followed by any amount of whitespace and a hyphen
        // - Then "Id:" and capture everything after it up to end of line
        let pattern = #"\* ActionTestSummary\s+- Id:\s+([^\s]+)"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, options: [], range: range)

        return matches.compactMap { match -> String? in
            guard match.numberOfRanges > 1,
                  let range = Range(match.range(at: 1), in: text) else {
                return nil
            }
            return String(text[range])
        }
    }
}
