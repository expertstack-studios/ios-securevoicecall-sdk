// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SecuredCallsVoiceSDK",
	platforms: [
		.iOS(.v16)
	],
	products: [
		.library(
			name: "SecuredCallsVoiceSDK",
			targets: ["SecuredCallsVoiceSDKWrapper"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", from: "1.5.4"),
		.package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.1"),
		.package(url: "https://github.com/Swinject/SwinjectAutoregistration.git", from: "2.8.4"),
		.package(url: "https://github.com/Vonage/vonage-client-sdk-ios", from: "1.6.0")
	],
	targets: [
		.binaryTarget(
			name: "SecuredCallsVoiceSDKBinary",
			path: "SDK/SecuredCallsVoiceSDK.xcframework"
		),
		.target(
			name: "SecuredCallsVoiceSDKWrapper",
			dependencies: [
				"SecuredCallsVoiceSDKBinary",
				.product(name: "Logging", package: "swift-log"),
				.product(name: "Swinject", package: "Swinject"),
				.product(name: "SwinjectAutoregistration", package: "SwinjectAutoregistration"),
				.product(name: "VonageClientSDK", package: "vonage-client-sdk-ios")
				.product(name: "VonageClientSDKVoice", package: "vonage-client-sdk-ios")
			],
			path: "./Sources/SecuredCallsVoiceSDKWrapper"
		)
	]
)
