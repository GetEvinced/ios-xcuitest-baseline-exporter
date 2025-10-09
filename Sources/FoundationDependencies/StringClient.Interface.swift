import Foundation

public struct StringClient {
    public var stringFromContentsOfURLEncoding: (_ url: URL, _ encoding: String.Encoding) throws -> String
    
    public init(stringFromContentsOfURLEncoding: @escaping (_: URL, _: String.Encoding) throws -> String) {
        self.stringFromContentsOfURLEncoding = stringFromContentsOfURLEncoding
    }
    
    public func string(
        contentsOf url: URL,
        encoding: String.Encoding
    ) throws -> String {
        try stringFromContentsOfURLEncoding(url, encoding)
    }
}
