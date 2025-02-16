// swift-tools-version: 5.6.1

import PackageDescription

let package = Package(
    name: "projectr",
    platforms: [.iOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0") // Or the version you want
    ],
    targets: [
        .executableTarget(name: "projectr", dependencies: [
            .product(name: "FirebaseFirestore", package: "firebase-ios-sdk") // Add other Firebase products as needed
        ]),
        .testTarget(name: "projectrTests", dependencies: ["projectr"]),
    ]
)