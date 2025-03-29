// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Fakeable",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "Fakeable",
            targets: ["Fakeable"]
        ),
        .executable(
            name: "FakeableClient",
            targets: ["FakeableClient"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", exact: "0.6.0")
    ],
    targets: [
        // Source code of the macro
        .target(
            name: "FakeableMacros",
            dependencies: [
                .target(name: "FakeableParameters"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "FakeableBridge",
            dependencies: [
                .target(name: "FakeableMacros"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "Fakeable",
            dependencies: [
                .target(name: "FakeableBridge"),
                .target(name: "FakeableParameters")
            ]
        ),
        .target(
            name: "FakeableParameters",
            dependencies: []
        ),
        .testTarget(
            name: "UnitTests",
            dependencies: [
                .target(name: "FakeableMacros"),
                .product(name: "MacroTesting", package: "swift-macro-testing")
            ]
        ),
        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "FakeableClient",
            dependencies: ["Fakeable"]
        )
    ]
)
