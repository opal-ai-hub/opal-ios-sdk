// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "OpalSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "OpalSDK",
            targets: ["OpalSDK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "OpalSDK",
            path: "OpalSDK.xcframework"
        )
    ]
)
