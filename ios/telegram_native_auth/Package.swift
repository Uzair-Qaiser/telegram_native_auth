// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "telegram_native_auth",
    platforms: [.iOS("15.0")],
    products: [
        .library(name: "telegram-native-auth", targets: ["telegram_native_auth"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "telegram_native_auth",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [.process("PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "TelegramNativeAuthTests",
            dependencies: ["telegram_native_auth"]
        )
    ]
)
