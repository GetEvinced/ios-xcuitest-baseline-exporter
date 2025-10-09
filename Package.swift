// swift-tools-version:5.9.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ios-xcuitest-baseline-exporter",
    platforms: [.macOS(.v13)],
    products: [
        .executable(
            name: "export-baselines",
            targets: ["ExportXCUIBaselines"]
        ),
        .library(
            name: "FoundationDependencies",
            targets: ["FoundationDependencies"]
        ),
        .library(
            name: "ExportXCUIBaselinesCore",
            targets: ["ExportXCUIBaselinesCore"]
        ),
        .library(
            name: "LoggingClient",
            targets: ["LoggingClient"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ExportXCUIBaselines",
            dependencies: [
                .target(
                    name: "ExportXCUIBaselinesCore"
                ),
                .target(
                    name: "LoggingClient"
                )
            ]
        ),
        .target(
            name: "FoundationDependencies"
        ),
        .target(
            name: "ExportXCUIBaselinesCore",
            dependencies: [
                .target(
                    name: "FoundationDependencies"
                ),
                .target(
                    name: "LoggingClient"
                )
            ]
        ),
        .target(
            name: "LoggingClient",
            dependencies: [
                .target(
                    name: "FoundationDependencies"
                )
            ]
        )
    ]
)
