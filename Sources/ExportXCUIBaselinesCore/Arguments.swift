import Foundation

public struct Arguments {
    public var xcResultPath: String
}

extension Arguments {
    public struct Error: Swift.Error {
        public let message: String
        
        init(message: String) {
            self.message = message
        }
    }

    public init(_ arguments: [String]) throws {
        guard
            arguments.count > 1,
            let args = Arg.parseArgs(arguments) as Optional,
            let xcResultPath = Arg.inBoundsPositional(in: args, at: 1), // first true positional (after executable)
            !xcResultPath.isEmpty
        else {
            throw Error(
                message: """
                Usage: ExportXCUIBaselines <xcresult-path>
                    xcresult-path: Path to .xcresult folder (CI or Xcode flow) or build folder (Xcode flow)
                """
            )
        }

        self.xcResultPath = xcResultPath
    }
}

extension Arguments {
    public enum Arg: Equatable {
        case option(name: String, value: String?)
        case positional(String)

        public static func parseArgs(_ a: [String]) -> [Arg] {
            var result: [Arg] = []
            var i = 0
            while i < a.count {
                let cur = a[i]
                let next = i + 1 < a.count ? a[i + 1] : nil

                if cur.hasPrefix("--") {
                    if let v = next, !v.hasPrefix("--") {
                        result.append(.option(name: cur, value: v))
                        i += 2
                    } else {
                        result.append(.option(name: cur, value: nil))
                        i += 1
                    }
                } else {
                    result.append(.positional(cur))
                    i += 1
                }
            }
            return result
        }
        
        public static func optionValue(
            for optionName: String,
            in args: [Self]
        ) -> String? {
            for arg in args {
                switch arg {
                case let .option(name, value) where name == optionName:
                    return value
                case .option, .positional:
                    return nil
                }
            }

            return nil
        }
        
        public static func hasOption(
            for optionName: String,
            in args: [Self]
        ) -> Bool {
            for arg in args {
                switch arg {
                case let .option(name, _):
                    if name == optionName {
                        return true
                    }
                case .positional:
                    continue
                }
            }

            return false
        }
        
        public static func positionals(in args: [Self]) -> [String] {
            args.reduce(into: []) { partialResult, arg in
                switch arg {
                case let .positional(value):
                    partialResult.append(value)
                case .option:
                    break
                }
            }
        }
        
        @inlinable
        public static func inBoundsPositional(
            in positionals: [String],
            at index: Int
        ) -> String? {
            positionals.indices.contains(index) ? positionals[index] : nil
        }
        
        @inlinable
        public static func inBoundsPositional(in args: [Self], at index: Int) -> String? {
            inBoundsPositional(
                in: positionals(in: args),
                at: index
            )
        }
    }
}
