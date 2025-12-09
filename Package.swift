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
		.package(url: "https://github.com/Vonage/vonage-client-sdk-ios", from: "2.1.3")
	],
	targets: [
		// Internal target — only SDK links Vonage Client SDK
		.target(
			name: "SCInternalDependencies",
			dependencies: [
				.product(name: "VonageClientSDK", package: "vonage-client-sdk-ios"),
				.product(name: "VonageClientSDKVoice", package: "vonage-client-sdk-ios")
			],
			path: "Sources/SCInternalDependencies",
			swiftSettings: [
				.define("SDK_INTERNAL") // Makes symbols hidden from consumers
			]
		),

		// Your binary SDK
		.binaryTarget(
			name: "SecuredCallsVoiceSDKBinary",
			path: "SDK/SecuredCallsVoiceSDK.xcframework"
		),

		// Public wrapper — only exposes your API, not Vonage’s
		.target(
			name: "SecuredCallsVoiceSDKWrapper",
			dependencies: [
				"SecuredCallsVoiceSDKBinary",
				"SCInternalDependencies" // Wraps Vonage inside your module
			],
			path: "./Sources/SecuredCallsVoiceSDKWrapper"
		)
	]
)
