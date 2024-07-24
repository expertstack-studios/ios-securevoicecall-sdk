// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SecuredCallsVoiceSDK",
	platforms: [
		.iOS(.v16),
	],
	products: [
		.library(
			name: "SecuredCallsVoiceSDK",
			targets: ["SecuredCallsVoiceSDK"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", from: "1.5.4"),
		.package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.1"),
		.package(url: "https://github.com/Swinject/SwinjectAutoregistration.git", from: "2.8.4"),
		.package(url: "https://github.com/Vonage/vonage-client-sdk-ios", from: "1.6.0"),
	],
	targets: [
		.binaryTarget(
			name: "SecuredCallsVoiceSDK",
			url: "https://es-sc-ios-branding-sdk.s3.ap-southeast-2.amazonaws.com/SecuredCallsVoiceSDK/SecuredCallsVoiceSDK.xcframework.zip",
			checksum: "5edb5c6b21c771edf07592f349b363560779aab4ebd0396264786f68f8c71e2b"
		),
	]
)
