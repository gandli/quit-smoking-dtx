// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "QuitSmokingDTx",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "QuitSmokingDTx",
            targets: ["QuitSmokingDTx"]),
    ],
    targets: [
        .target(
            name: "QuitSmokingDTx",
            path: "QuitSmokingDTxApp",
            resources: [
                .process("Resources")
            ]
        )
    ]
)