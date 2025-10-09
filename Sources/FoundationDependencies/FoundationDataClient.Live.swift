import Foundation

extension FoundationDataClient {
    public static var live: Self {
        Self(
            writeDataToURLWithOptions: { data, toURL, options in
                try data.write(to: toURL, options: options)
            },
            dataWithContentsOf: { url, options in
                try Data(
                    contentsOf: url,
                    options: options
                )
            }
        )
    }
}
