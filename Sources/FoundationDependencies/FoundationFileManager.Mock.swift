#if DEBUG
import Foundation

extension FoundationFileManager {
    public static var mock: Self {
        Self(
            isReadableFileAtPath: { _ in false },
            removeItemAtPath: { _ in },
            fileExistsAtPath: { _ in false },
            moveItemAtSourceURLToDestinationURL: { _, _ in },
            urlForDirectoryInDomainAppropriateForURLShouldCreate: { _, _, _, _ in
                Foundation.URL.mockUrlForDirectoryInDomain
            },
            createFileAtPathContentsAttributes: { _, _, _ in
                false
            },
            temporaryDirectory: {
                Foundation.URL.mockTempDirectory
            },
            createDirectoryAtURLWithIntermediateDirectoriesAttributes: { _, _, _ in },
            removeItemAtURL: { _ in },
            createDirectoryAtPathWithIntermediateDirectoriesAttributes: { _, _, _ in },
            copyItemAtPathToPath: { _, _ in },
            contentsOfDirectoryAtURLIncludingPropertiesForKeysOptionsMask: { _, _, _ in  [] },
            copyItemAtURLToURL: { _, _ in }
        )
    }
}

extension URL {
    public static var mock: URL { URL(string: "https://mock.mock").unsafelyUnwrapped }
    public static var mockTempDirectory: URL { URL(fileURLWithPath: "/Mock/Temp/Directory") }
    public static var mockUrlForDirectoryInDomain: URL { URL(fileURLWithPath: "/Mock/URL/For/Directory/In/Domain") }
}

#endif
