import Foundation
import FoundationDependencies

public struct LoggingClient {
    private let subsystem: String
    private let category: String
    public static let isoStyle = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    public var dateNow: Date.Now
    public var logMessage: (_ message: String) -> Void
    
    public init(
        subsystem: String,
        category: String,
        dateNow: Date.Now,
        logMessage: @escaping (_ message: String) -> Void
    ) {
        self.subsystem = subsystem
        self.category = category
        self.dateNow = dateNow
        self.logMessage = logMessage
    }

    // MARK: - Logging methods

    public func debug(_ message: String) {
        logMessage(message, type: .debug)
    }

    public func info(_ message: String) {
        logMessage(message, type: .info)
    }

    public func notice(_ message: String) {
        logMessage(message, type: .default) // "notice"
    }

    public func warning(_ message: String) {
        logMessage(message, type: .warning) // no dedicated warning, map to error
    }

    public func error(_ message: String) {
        logMessage(message, type: .error)
    }

    public func critical(_ message: String) {
        logMessage(message, type: .fault)
    }

    // MARK: - Core

    private func logMessage(_ message: String, type: LogType) {
        self.logMessage(
            Self.message(
                message: message,
                dateNow: dateNow,
                type: type,
                subsystem: subsystem,
                category: category
            )
        )
    }
    
    @inlinable
    public static func message(
        message: String,
        dateNow: Date.Now,
        type: LogType,
        subsystem: String,
        category: String
    ) -> String {
        "[\(dateNow().formatted(Self.isoStyle))] [\(Self.pretty(type))] [\(subsystem):\(category)] \(message)"
    }
    
    public static func pretty(_ type: LogType) -> String {
        switch type {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .default: return "NOTICE"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        case .fault: return "CRITICAL"
        }
    }
}

extension LoggingClient {
    public struct Create {
        public var create: (
            _ subsystem: String,
            _ category: String
        ) -> LoggingClient
        
        public init(
            create: @escaping (_: String, _: String) -> LoggingClient
        ) {
            self.create = create
        }
        
        public func callAsFunction(
            subsystem: String,
            category: String
        ) -> LoggingClient {
            create(
                subsystem,
                category
            )
        }
    }
}

extension LoggingClient {
    public enum LogType {
        case debug
        case info
        case `default`
        case warning
        case error
        case fault
    }
}
