#if DEBUG

import Foundation

extension Date.Now {
    public static var mock: Self {
        Self(now: { .mock })
    }
}

extension Date {
    public static var mock: Self {
        Date(timeIntervalSince1970: 0)
    }
}

#endif
