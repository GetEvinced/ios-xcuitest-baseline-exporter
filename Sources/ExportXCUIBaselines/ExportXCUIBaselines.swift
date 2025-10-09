import Foundation
import FoundationDependencies
import ExportXCUIBaselinesCore
import LoggingClient

@main
struct ExportXCUIBaselines {
    static func main() async throws {
        
        let arguments: Arguments
        
        do {
            arguments = try Arguments(CommandLine.arguments)
        } catch let error as Arguments.Error {
            print(error.message)
            return
        }
        
        try await ExportXCUIBaselinesCore.run(
            xcresult: arguments.xcResultPath,
            fileManager: .live,
            uuidGen: .live,
            createUrlClient: .live,
            processClient: .live,
            createLogging: .live,
            dataClient: .live,
            stringClient: .live
        )
    }
}
