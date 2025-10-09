extension StringClient {
    public static var mock: Self {
        Self(stringFromContentsOfURLEncoding: { _, _ in "" })
    }
}
