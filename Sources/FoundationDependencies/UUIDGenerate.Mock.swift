#if DEBUG
import Foundation

extension UUIDGenerate {
    public static var mock: Self { Self(generate: { .mock }) }
}

extension UUID {
    public static var mock: Self {
        Self(0)
    }
}

#endif
