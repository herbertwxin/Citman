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
            exclude: ["Info.plist"],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/Citman/Info.plist"
                ])
            ]
        )
    ]
)
