import Foundation

extension Date.Now {
    public static var live: Self {
        .init(now: { Date() })
    }
}
