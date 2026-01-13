// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Citman",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Citman", targets: ["Citman"])
    ],
    targets: [
        .executableTarget(
            name: "Citman",
            path: "Sources/Citman",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "CitmanTests",
            dependencies: ["Citman"]
        )
    ]
)