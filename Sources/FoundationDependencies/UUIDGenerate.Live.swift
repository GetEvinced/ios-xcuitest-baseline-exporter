import Foundation

extension UUIDGenerate {
    public static var live: Self {
        .init(generate: { UUID() })
    }
}
