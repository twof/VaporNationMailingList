// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "MailingList",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-beta"),
        .package(url: "https://github.com/twof/VaporMailgunService.git", from: "0.0.1")
        ],
    targets: [
        .target(name: "App", dependencies: [
            "Vapor",
            "Mailgun"
            ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
        ]
)
