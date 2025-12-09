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
		// Swinject Dependencies
		.package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.1"),
		.package(url: "https://github.com/Swinject/SwinjectAutoregistration.git", from: "2.9.1"),

		// Vonage SDK
		.package(url: "https://github.com/Vonage/vonage-client-sdk-ios", from: "2.1.3")
	],
	targets: [
		// Internal target — wraps all Vonage usage
		.target(
			name: "SCInternalDependencies",
			dependencies: [
				.product(name: "VonageClientSDK", package: "vonage-client-sdk-ios"),
				.product(name: "VonageClientSDKVoice", package: "vonage-client-sdk-ios")
			],
			path: "Sources/SCInternalDependencies",
			swiftSettings: [
				.define("SDK_INTERNAL")
			]
		),

		// Your binary XCFramework (must NOT contain Swinject inside!)
		.binaryTarget(
			name: "SecuredCallsVoiceSDKBinary",
			path: "SDK/SecuredCallsVoiceSDK.xcframework"
		),

		// Public wrapper — exposes your SDK API
		.target(
			name: "SecuredCallsVoiceSDKWrapper",
			dependencies: [
				"SecuredCallsVoiceSDKBinary",
				"SCInternalDependencies",

				// External DI libs (must NOT be in the binary)
				.product(name: "Swinject", package: "Swinject"),
				.product(name: "SwinjectAutoregistration", package: "SwinjectAutoregistration")
			],
			path: "./Sources/SecuredCallsVoiceSDKWrapper"
		)
	]
)
