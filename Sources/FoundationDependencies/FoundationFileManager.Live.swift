import Foundation

extension FoundationFileManager {
    public static var live: Self {
        Self(
            isReadableFileAtPath: { fileAtPath in
                FileManager.default.isReadableFile(atPath: fileAtPath)
            },
            removeItemAtPath: { fileAtPath in
                try FileManager.default.removeItem(atPath: fileAtPath)
            },
            fileExistsAtPath: { fileAtPath in
                FileManager.default.fileExists(atPath: fileAtPath)
            },
            moveItemAtSourceURLToDestinationURL: { srcURL, dstURL in
                try FileManager.default.moveItem(
                    at: srcURL,
                    to: dstURL
                )
            },
            urlForDirectoryInDomainAppropriateForURLShouldCreate: { forDirectory, inDomain, appropriateForURL, shouldCreate in
                try FileManager.default.url(
                    for: forDirectory,
                    in: inDomain,
                    appropriateFor: appropriateForURL,
                    create: shouldCreate
                )
            },
            createFileAtPathContentsAttributes: { atPath, contents, attributes in
                FileManager.default.createFile(
                    atPath: atPath,
                    contents: contents,
                    attributes: attributes
                )
            },
            temporaryDirectory: {
                FileManager.default.temporaryDirectory
            },
            createDirectoryAtURLWithIntermediateDirectoriesAttributes: { atURL, createIntermediates, attributes in
                try FileManager.default.createDirectory(
                    at: atURL,
                    withIntermediateDirectories: createIntermediates,
                    attributes: attributes
                )
            },
            removeItemAtURL: { url in
                try FileManager.default.removeItem(at: url)
            },
            createDirectoryAtPathWithIntermediateDirectoriesAttributes: { atPath, withIntermediateDirectories, attributes in
                try FileManager.default.createDirectory(
                    atPath: atPath,
                    withIntermediateDirectories: withIntermediateDirectories,
                    attributes: attributes
                )
            },
            copyItemAtPathToPath: { atSrcPath, toDstPath in
                try FileManager.default.copyItem(
                    atPath: atSrcPath,
                    toPath: toDstPath
                )
            },
            contentsOfDirectoryAtURLIncludingPropertiesForKeysOptionsMask: { atURL, includingPropertiesForKeys, optionsMask in
                try FileManager.default.contentsOfDirectory(
                    at: atURL,
                    includingPropertiesForKeys: includingPropertiesForKeys,
                    options: optionsMask
                )
            },
            copyItemAtURLToURL: { srcURL, dstURL in
                try FileManager.default.copyItem(at: srcURL, to: dstURL)
            }
        )
    }
}
