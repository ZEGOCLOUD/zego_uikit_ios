// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZegoUIKit",
    
    platforms: [.iOS(.v12)],
    
    products: [
        .library(
            name: "ZegoUIKit",
            targets: ["ZegoUIKit","ZegoUIKitSDK"]),
    ],
    
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/zegolibrary/express-video-ios", "3.2.0"..."3.3.0"),
        .package(url: "https://github.com/ZEGOCLOUD/zego_plugin_adapter_ios.git", from: "2.0.0"),
    ],
    
    targets: [
        .target(name: "ZegoUIKit",dependencies: [
            .product(name: "ZegoPluginAdapter", package: "zego_plugin_adapter_ios"),
            .product(name: "ZegoExpressEngine", package: "express-video-ios")]),
        
            .binaryTarget(name: "ZegoUIKitSDK", url: "https://github.com/ZEGOCLOUD/zego_uikit_ios/releases/download/2.0.0/ZegoUIKitSDK.xcframework.zip", checksum: "e8c54c0d24a5f803c9d642dce386f31bcb2a68cdcab55e1fdc78ad0cedc3db9b"),
        
    ]
)
