#if DEBUG
import Foundation
import FoundationDependencies

extension LoggingClient {
    public static func mock(
        subsystem: String = "mockSubsystem",
        category: String = "mockCategory",
        dateNow: Date.Now = .mock,
        logMessage: @escaping (_ message: String) -> Void = { _ in }
    ) -> Self {
        Self(
            subsystem: subsystem,
            category: category,
            dateNow: dateNow,
            logMessage: logMessage
        )
    }
}

extension LoggingClient.Create {
    public static var mock: Self {
        Self(
            create: { _, _ in
                .mock()
            }
        )
    }
}
#endif
