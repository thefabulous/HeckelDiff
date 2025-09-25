// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "HeckelDiff",
    products: [
        .library(name: "HeckelDiff", targets: ["HeckelDiff"]),
    ],
    targets: [
        .target(name: "HeckelDiff", path: "Source"),
    ]
)