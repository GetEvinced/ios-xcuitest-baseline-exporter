import Foundation
import FoundationDependencies
import LoggingClient

enum BaselineProcessor {
    enum Kind: String {
        case baseline = "baseline"
        case manifest = "baseline_manifest"
    }
    
    static func regExp() throws -> NSRegularExpression {
        let pattern = #"^(.+?)\.(baseline|baseline_manifest)_\d+_[A-Fa-f0-9-]{36}\.json$"#
        return try NSRegularExpression(pattern: pattern, options: [])
    }
    
    static func parse(_ filename: String, nameRegex: NSRegularExpression) -> (key: String, kind: Kind)? {
        let range = NSRange(filename.startIndex..<filename.endIndex, in: filename)
        guard let m = nameRegex.firstMatch(in: filename, options: [], range: range) else { return nil }
        guard
            let keyRange = Range(m.range(at: 1), in: filename),
            let kindRange = Range(m.range(at: 2), in: filename),
            let kind = Kind(rawValue: String(filename[kindRange]))
        else { return nil }
        
        let key = String(filename[keyRange]) // e.g. "BaselineComparisonTests.test_recordMode.1178x2556"
        return (key, kind)
    }
    
    static func manifestEntries(
        _ manifestPath: String,
        dataClient: FoundationDataClient,
        decode: (Data) throws -> [Entry] = { data in try JSONDecoder().decode([Entry].self, from: data) }
    ) throws -> [Entry] {
        let data = try dataClient
            .dataWithContentsOf(url: URL(fileURLWithPath: manifestPath))
        return try decode(data)
    }
    
    static func processManifest(
        mappings: (baselineFiles: [String: String], automationManifestFiles: [String: String]),
        in attachmentsDir: String,
        fileManager: FoundationFileManager,
        fileManagerLogger: LoggingClient,
        overridingAutomationBaselineDirectory: URL?
    ) throws -> Int {
        let (baselineFiles, automationManifestFiles) = mappings
        
        var copiedCount = 0
        
        for key in baselineFiles.keys {
            guard
                let baselineFile = baselineFiles[key],
                let automationManifestFile = automationManifestFiles[key]
            else {
                continue
            }
            
            let manifestPath = "\(attachmentsDir)/\(automationManifestFile)"
            guard
                let manifestData = try? Data(contentsOf: URL(fileURLWithPath: manifestPath)),
                let automation = try? JSONDecoder().decode(AutomationFile.self, from: manifestData)
            else {
                continue
            }
            
            let sourcePath = "\(attachmentsDir)/\(baselineFile)"
            let targetDir = overridingAutomationBaselineDirectory ?? automation.baselineComparisonFolderURL
            let destinationURL = targetDir.appending(component: automation.baselineFileName)
            
            try fileManager.createDirectory(
                atPath: targetDir.path(percentEncoded: false),
                withIntermediateDirectories: true
            )
            
            let destinationPath = destinationURL.path(percentEncoded: false)
            
            if fileManager.fileExists(atPath: destinationPath) {
                try fileManager.removeItem(atPath: destinationPath)
            }
            
            try fileManager.copyItem(
                atPath: sourcePath,
                toPath: destinationPath
            )
            
            fileManagerLogger.info("Copied: \(baselineFile) -> \(destinationPath)")
            copiedCount += 1
        }
        
        return copiedCount
    }
    
    static func baselineAndAutomationManifestMappings(
        entries: [Entry],
        nameRegex: NSRegularExpression
    ) -> (baselineFiles: [String: String], automationManifestFiles: [String: String]) {
        var baselineFiles: [String: String] = [:]
        var automationManifestFiles: [String: String] = [:]
        
        for entry in entries {
            for attachment in entry.attachments {
                let name = attachment.suggestedHumanReadableName
                guard let parsed = Self.parse(name, nameRegex: nameRegex) else { continue }
                switch parsed.kind {
                case .baseline:
                    baselineFiles[parsed.key] = attachment.exportedFileName
                case .manifest:
                    automationManifestFiles[parsed.key] = attachment.exportedFileName
                }
            }
        }
        
        return (baselineFiles, automationManifestFiles)
    }
    
    /// Strips a trailing `_<index>_<UUID>` that appears right before the file extension.
    /// Example:
    /// "BaselineComparisonTests.test_recordMode.1178x2556.baseline_0_A4A0FEBF-BD4F-404C-A999-D437A294B483.json"
    /// -> "BaselineComparisonTests.test_recordMode.1178x2556.baseline.json"
    static func stripIndexUUID(from filename: String) -> String {
        let url = URL(fileURLWithPath: filename)
        let ext = url.pathExtension
        let base = url.deletingPathExtension().lastPathComponent

        // Matches: _<digits>_<UUID> at the very end of the base name
        let pattern = #/_\d+_[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$/#

        let cleanedBase = base.replacing(pattern, with: "")
        let dir = url.deletingLastPathComponent()

        if ext.isEmpty {
            return dir.appendingPathComponent(cleanedBase)
                .path(percentEncoded: false)
        } else {
            return dir.appendingPathComponent(cleanedBase)
                .appendingPathExtension(ext)
                .path(percentEncoded: false)
        }
    }
    
    // Convenience for URLs
    static func stripIndexUUID(from url: URL) -> URL {
        URL(fileURLWithPath: stripIndexUUID(from: url.path))
    }
}
