import Foundation

public struct FoundationFileManager {
    public var isReadableFileAtPath: (String) -> Bool
    public var removeItemAtPath: (_ atPath: String) throws -> Void
    public var fileExistsAtPath: (_ path: String) -> Bool
    public var moveItemAtSourceURLToDestinationURL: (
        _ srcURL: URL,
        _ dstURL: URL
    ) throws -> Void
    public var urlForDirectoryInDomainAppropriateForURLShouldCreate: (
        _ forDirectory: FileManager.SearchPathDirectory,
        _ inDomain: FileManager.SearchPathDomainMask,
        _ appropriateForURL: URL?,
        _ shouldCreate: Bool
    ) throws -> URL
    public var createFileAtPathContentsAttributes: (
        _ atPath: String,
        _ contents: Data?,
        _ attributes: [FileAttributeKey: Any]?
    ) -> Bool
    
    public var temporaryDirectory: () -> URL
    
    public var createDirectoryAtURLWithIntermediateDirectoriesAttributes: (
        _ atURL: URL,
        _ createIntermediates: Bool,
        _ attributes: [FileAttributeKey : Any]?) throws -> Void
    
    public var removeItemAtURL: (_ url: URL) throws -> Void
    
    public var createDirectoryAtPathWithIntermediateDirectoriesAttributes: (
        _ atPath: String,
        _ withIntermediateDirectories: Bool,
        _ attributes: [FileAttributeKey : Any]?
    ) throws -> Void
    
    public var copyItemAtPathToPath: (
        _ atSrcPath: String,
        _ toDstPath: String
    ) throws -> Void
    
    
    public var contentsOfDirectoryAtURLIncludingPropertiesForKeysOptionsMask: (
        _ atURL: URL,
        _ includingPropertiesForKeys: [URLResourceKey]?,
        _ optionsMask: FileManager.DirectoryEnumerationOptions
    ) throws -> [URL]
    
    public var copyItemAtURLToURL: (_ atSrcURL: URL, _ toDstURL: URL) throws -> Void
        
    public init(
        isReadableFileAtPath: @escaping (String) -> Bool,
        removeItemAtPath: @escaping (_: String) throws -> Void,
        fileExistsAtPath: @escaping (_: String) -> Bool,
        moveItemAtSourceURLToDestinationURL: @escaping (_: URL, _: URL) throws -> Void,
        urlForDirectoryInDomainAppropriateForURLShouldCreate: @escaping (_: FileManager.SearchPathDirectory, _: FileManager.SearchPathDomainMask, _: URL?, _: Bool) throws -> URL,
        createFileAtPathContentsAttributes: @escaping (_: String, _: Data?, _: [FileAttributeKey : Any]?) -> Bool,
        temporaryDirectory: @escaping () -> URL,
        createDirectoryAtURLWithIntermediateDirectoriesAttributes: @escaping (_: URL, _: Bool, _: [FileAttributeKey : Any]?) throws -> Void,
        removeItemAtURL: @escaping (_: URL) throws -> Void,
        createDirectoryAtPathWithIntermediateDirectoriesAttributes: @escaping (_: String, _: Bool, _: [FileAttributeKey : Any]?) throws -> Void,
        copyItemAtPathToPath: @escaping (_: String, _: String) throws -> Void,
        contentsOfDirectoryAtURLIncludingPropertiesForKeysOptionsMask: @escaping (_: URL, _: [URLResourceKey]?, _: FileManager.DirectoryEnumerationOptions) throws -> [URL],
        copyItemAtURLToURL: @escaping (_: URL, _: URL) throws -> Void
    ) {
        self.isReadableFileAtPath = isReadableFileAtPath
        self.removeItemAtPath = removeItemAtPath
        self.fileExistsAtPath = fileExistsAtPath
        self.moveItemAtSourceURLToDestinationURL = moveItemAtSourceURLToDestinationURL
        self.urlForDirectoryInDomainAppropriateForURLShouldCreate = urlForDirectoryInDomainAppropriateForURLShouldCreate
        self.createFileAtPathContentsAttributes = createFileAtPathContentsAttributes
        self.temporaryDirectory = temporaryDirectory
        self.createDirectoryAtURLWithIntermediateDirectoriesAttributes = createDirectoryAtURLWithIntermediateDirectoriesAttributes
        self.removeItemAtURL = removeItemAtURL
        self.createDirectoryAtPathWithIntermediateDirectoriesAttributes = createDirectoryAtPathWithIntermediateDirectoriesAttributes
        self.copyItemAtPathToPath = copyItemAtPathToPath
        self.contentsOfDirectoryAtURLIncludingPropertiesForKeysOptionsMask = contentsOfDirectoryAtURLIncludingPropertiesForKeysOptionsMask
        self.copyItemAtURLToURL = copyItemAtURLToURL
    }
    
    public func isReadableFile(atPath path: String) -> Bool {
        isReadableFileAtPath(path)
    }
    
    public func removeItem(atPath path: String) throws {
        try removeItemAtPath(path)
    }
    
    public func fileExists(atPath path: String) -> Bool {
        fileExistsAtPath(path)
    }
    
    public func moveItem(
        at srcURL: URL,
        to dstURL: URL
    ) throws {
        try moveItemAtSourceURLToDestinationURL(srcURL, dstURL)
    }
    
    public func url(
        for directory: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask,
        appropriateFor url: URL?,
        create shouldCreate: Bool
    ) throws -> URL {
        try urlForDirectoryInDomainAppropriateForURLShouldCreate(
            directory,
            domain,
            url,
            shouldCreate
        )
    }
    
    public func createFile(
        atPath path: String,
        contents data: Data?,
        attributes attr: [FileAttributeKey: Any]? = nil
    ) -> Bool {
        createFileAtPathContentsAttributes(
            path,
            data,
            attr
        )
    }
    
    public func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey : Any]? = nil
    ) throws {
        try createDirectoryAtURLWithIntermediateDirectoriesAttributes(
            url,
            createIntermediates,
            attributes
        )
    }
    
    public func removeItem(at url: URL) throws {
        try removeItemAtURL(url)
    }
    
    public func createDirectory(
        atPath path: String,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey : Any]? = nil
    ) throws {
        try createDirectoryAtPathWithIntermediateDirectoriesAttributes(
            path,
            createIntermediates,
            attributes
        )
    }
    
    public func copyItem(
        atPath srcPath: String,
        toPath dstPath: String
    ) throws {
        try copyItemAtPathToPath(
            srcPath,
            dstPath
        )
    }
    
    public func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options mask: FileManager.DirectoryEnumerationOptions = []
    ) throws -> [URL] {
        try contentsOfDirectoryAtURLIncludingPropertiesForKeysOptionsMask(
            url,
            keys,
            mask
        )
    }
    
    public func copyItem(at srcURL: URL, to dstURL: URL) throws {
        try copyItemAtURLToURL(srcURL, dstURL)
    }
}
