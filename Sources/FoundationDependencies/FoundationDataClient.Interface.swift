import Foundation

public struct FoundationDataClient {
    public var writeDataToURLWithOptions: (
        _ data: Data,
        _ toURL: URL,
        _ options: Data.WritingOptions
    ) throws -> Void
    
    public var dataWithContentsOf: (
        _ url: URL,
        _ options: Data.ReadingOptions
    ) throws -> Data
    
    public init(
        writeDataToURLWithOptions: @escaping (_: Data, _: URL, _: Data.WritingOptions) throws -> Void,
        dataWithContentsOf: @escaping (_: URL, _: Data.ReadingOptions) throws -> Data
    ) {
        self.writeDataToURLWithOptions = writeDataToURLWithOptions
        self.dataWithContentsOf = dataWithContentsOf
    }
    
    public func write(
        data: Data,
        to url: URL,
        options: Data.WritingOptions = []
    ) throws {
        try writeDataToURLWithOptions(data, url, options)
    }
    
    public func dataWithContentsOf(
        url: URL,
        options: Data.ReadingOptions = []
    ) throws -> Data {
        try self.dataWithContentsOf(url, options)
    }
}
