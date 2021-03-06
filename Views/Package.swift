// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Views",
    defaultLocalization: "en",
    platforms: [
         .macOS(.v12),
         .macCatalyst(.v15),
         .iOS(.v15),
     ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Views",
            targets: ["Views"]),
    ],
    dependencies: [
        .package(name: "DataModel", path: "../DataModel"),
        .package(name: "ViewModels", path: "../ViewModels"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "ImageRecognizer", path: "../ImageRecognizer")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Views",
            dependencies: ["DataModel", "ViewModels", "ImageRecognizer", "Localization"]),
        .testTarget(
            name: "ViewsTests",
            dependencies: ["Views"]),
    ]
)
