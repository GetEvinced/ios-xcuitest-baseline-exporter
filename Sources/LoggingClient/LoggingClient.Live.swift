import Foundation
import FoundationDependencies
extension LoggingClient.Create {
    public static var live: Self {
        Self(
            create: { subsystem, category in
                .init(
                    subsystem: subsystem,
                    category: category,
                    dateNow: .live,
                    logMessage: { message in
                        fputs("\(message)\n", stderr)
                    }
                )
            }
        )
    }
}
