import Foundation

extension UUID {
    // swiftlint:disable force_unwrapping    
    /// Instantiates UUID with passed integer. Useful during unit testing where it is required to get reproducible results.
    /// - Parameter intValue: integer value to be encoded into UUID.
    public init(_ intValue: Int) {
        self.init(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", intValue))")!
    }
    // swiftlint:enable force_unwrapping
    
    /// Returns closure, each call of which will produce auto incremented UUID by one. Useful during unit testing where it is required to get reproducible results.
    public static var incrementing: () -> UUID {
        var uuid = 0
        return {
            defer { uuid += 1 }
            return Self(uuid)
        }
    }
}

public struct UUIDGenerate {
    public var generate: () -> UUID
    
    public init(generate: @escaping () -> UUID) {
        self.generate = generate
    }
    
    public func callAsFunction() -> UUID {
        generate()
    }
}

