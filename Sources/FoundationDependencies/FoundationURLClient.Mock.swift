#if DEBUG
import Foundation

extension FoundationURLClient {
    public static var mock: Self { Self { _ in .mock } }
}

extension URLResourceValues {
    public static var mock: Self { Self() }
}
#endif
