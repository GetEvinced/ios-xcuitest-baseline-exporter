#if DEBUG
import Foundation

extension FoundationDataClient {
    static var mock: Self {
        Self(
            writeDataToURLWithOptions: { _, _, _ in },
            dataWithContentsOf: { _, _ in
                .mock
            }
        )
    }
}

extension Data {
    public static var mock: Self { Data() }
}
#endif
