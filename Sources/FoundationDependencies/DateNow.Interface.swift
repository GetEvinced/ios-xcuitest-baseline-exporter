import Foundation

extension Date {
    public struct Now {
        public var now: () -> Date
        
        public init(now: @escaping () -> Date) {
            self.now = now
        }
        
        public func callAsFunction() -> Date {
            now()
        }
    }
}
