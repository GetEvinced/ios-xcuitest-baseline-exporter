#if DEBUG
extension ProcessClient {
    public static var mock: Self {
        Self(
            runWithOutput: { _, _, _ in .mock }
        )
    }
}

extension ProcessClient.CollectedResult {
    public static var mock: Self {
        Self(
            standardOutput: "mockStandardOutput",
            standardError: "mockStandardError"
        )
    }
}
#endif
