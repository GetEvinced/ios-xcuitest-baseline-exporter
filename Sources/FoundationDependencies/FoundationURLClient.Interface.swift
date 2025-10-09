import Foundation

/// A wrapper around foundation URL to be able to alter some of it's behaviour in unit tests.
public struct FoundationURLClient {
    public var resourceValuesForKeys: (Set<URLResourceKey>) throws -> URLResourceValues
    
    public init(resourceValuesForKeys: @escaping (Set<URLResourceKey>) throws -> URLResourceValues) {
        self.resourceValuesForKeys = resourceValuesForKeys
    }
    
    public func resourceValues(forKeys keys: Set<URLResourceKey>) throws -> URLResourceValues {
        try resourceValuesForKeys(keys)
    }
}

extension FoundationURLClient {
    public struct Create {
        public var create: (URL) -> FoundationURLClient
        
        public init(create: @escaping (URL) -> FoundationURLClient) {
            self.create = create
        }
        
        public func callAsFunction(url: URL) -> FoundationURLClient {
            create(url)
        }
    }
}
