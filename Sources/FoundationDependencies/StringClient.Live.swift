extension StringClient {
    public static var live: Self {
        Self(
            stringFromContentsOfURLEncoding: { url, encoding in
                try String(contentsOf: url, encoding: encoding)
            }
        )
    }
}
