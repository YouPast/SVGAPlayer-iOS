//
//  Package.swift
//  SVGAPlayer
//
//  Created by smartzou on 2025/1/3.
//  Copyright © 2025 UED Center. All rights reserved.
//

// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "SVGAPlayer",
    platforms: [
        .iOS(.v11) // CocoaPods 支持 iOS 7.0，但 SPM 最低支持 iOS 8.0，这里推荐设置为更高的版本。
    ],
    products: [
        .library(
            name: "SVGAPlayer",
            targets: ["SVGAPlayerCore", "SVGAPlayerProtoFiles"]
        ),
        .library(
            name: "SVGAPlayerCore",
            targets: ["SVGAPlayerCore"]
        ),
        .library(
            name: "SVGAPlayerProtoFiles",
            targets: ["SVGAPlayerProtoFiles"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ZipArchive/ZipArchive.git", from: "1.8.1"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SVGAPlayerCore",
            dependencies: [
                .product(name: "SSZipArchive", package: "ZipArchive"),
                "SVGAPlayerProtoFiles"
            ],
            path: "Source",
            exclude: ["pbobjc"],
            sources: ["."],
            publicHeadersPath: ".", // 如果有需要公开的头文件
            cSettings: [
                .headerSearchPath("."),
                .define("GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS", to: "1") // 如果需要定义宏
            ],
            linkerSettings: [
                .linkedLibrary("z"),
                .linkedFramework("AVFoundation")
            ]
        ),
        .target(
            name: "SVGAPlayerProtoFiles",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf")
            ],
            path: "Source/pbobjc",
            sources: ["."],
            publicHeadersPath: "." // 如果有需要公开的头文件
        ),
        .testTarget(
            name: "SVGAPlayerTests",
            dependencies: ["SVGAPlayerCore"],
            path: "Tests"
        )
    ]
)
