// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WireGuardKit",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(name: "WireGuardKit", targets: ["WireGuardKit"]),
        // boring-ops fork addition: expose the wg-quick parser as
        // its own SPM product. Upstream keeps this code under
        // Sources/Shared/ and consumes it from WireGuardApp's UI
        // target only — meaning embedders of WireGuardKit as a
        // library (like our boring-ops NE Provider) can't reach
        // `TunnelConfiguration(fromWgQuickConfig:called:)` without
        // either copying the file or extending the package
        // manifest. This product takes the second path.
        .library(name: "WireGuardKitWgQuickParser", targets: ["WireGuardKitWgQuickParser"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WireGuardKit",
            dependencies: ["WireGuardKitGo", "WireGuardKitC"]
        ),
        .target(
            name: "WireGuardKitC",
            dependencies: [],
            publicHeadersPath: "."
        ),
        .target(
            name: "WireGuardKitGo",
            dependencies: [],
            exclude: [
                "goruntime-boottime-over-monotonic.diff",
                "go.mod",
                "go.sum",
                "api-apple.go",
                "Makefile"
            ],
            publicHeadersPath: ".",
            linkerSettings: [.linkedLibrary("wg-go")]
        ),
        // boring-ops fork addition: the wg-quick parser extension on
        // TunnelConfiguration, plus the String+ArrayConversion
        // helper it depends on. The third file in Shared/Model
        // (NETunnelProviderProtocol+Extension.swift) is excluded
        // because it imports NetworkExtension framework — that's
        // an app-side concern, and embedders of this parser
        // shouldn't have NE force-linked into their dep graph.
        .target(
            name: "WireGuardKitWgQuickParser",
            dependencies: ["WireGuardKit"],
            path: "Sources/Shared/Model",
            exclude: ["NETunnelProviderProtocol+Extension.swift"]
        )
    ]
)
