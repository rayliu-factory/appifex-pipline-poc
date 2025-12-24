// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TodoApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "TodoApp",
            targets: ["TodoApp"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.0"),
        .package(url: "https://github.com/pointfreeco/swift-navigation", from: "2.2.0"),
        .package(url: "https://github.com/hmlongco/Factory", from: "2.3.0"),
    ],
    targets: [
        .target(
            name: "TodoApp",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SwiftNavigation", package: "swift-navigation"),
                .product(name: "Factory", package: "Factory"),
            ]
        ),
        .testTarget(
            name: "TodoAppTests",
            dependencies: ["TodoApp"]
        ),
    ]
)
