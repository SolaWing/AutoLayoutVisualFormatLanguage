// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "VFL",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "VFL", targets: ["VFL", "AutoLayoutVisualFormat"]),
    ],
    targets: [
        .target(name: "AutoLayoutVisualFormat", dependencies: [], path: "AutoLayoutVisualFormat", publicHeadersPath: "."),
        .target(name: "VFL", dependencies: ["AutoLayoutVisualFormat"], path: "VFL"),
        .testTarget(name: "Tests", dependencies: ["VFL"], path: "Tests"),
    ]
)
