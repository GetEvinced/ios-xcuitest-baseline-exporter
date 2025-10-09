import Foundation

extension FoundationURLClient {
    static func live(url: URL) -> Self {
        Self { resourceKeys in
            try url.resourceValues(forKeys: resourceKeys)
        }
    }
}

extension FoundationURLClient.Create {
    public static var live: Self {
        Self { url in
            .live(url: url)
        }
    }
}
