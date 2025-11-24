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
	targets: [
		.binaryTarget(
			name: "SecuredCallsVoiceSDKBinary",
			path: "SDK/SecuredCallsVoiceSDK.xcframework"
		),
		.target(
			name: "SecuredCallsVoiceSDKWrapper",
			path: "./Sources/SecuredCallsVoiceSDKWrapper"
		)
	]
)
