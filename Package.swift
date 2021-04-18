// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TicketsRepository",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TicketsRepository",
            targets: ["TicketsRepository"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
		.package(url: "https://github.com/bogdanovkv/TicketsRepositoryAbstraction.git", from: "1.0.0"),
		.package(name: "NetworkAbstraction",url: "https://github.com/bogdanovkv/NetworkAbstration.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TicketsRepository",
			dependencies: [.byName(name: "TicketsRepositoryAbstraction"), .byName(name:"NetworkAbstraction")]),
        .testTarget(
            name: "TicketsRepositoryTests",
            dependencies: ["TicketsRepository"]),
    ]
)
