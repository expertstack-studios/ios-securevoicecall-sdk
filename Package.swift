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
	targets: [
		.binaryTarget(
			name: "SecuredCallsVoiceSDK",
			url: "https://es-sc-ios-branding-sdk.s3.ap-southeast-2.amazonaws.com/SecuredCallsVoiceSDK/SecuredCallsVoiceSDK.xcframework.zip",
			checksum: "6fb88500b9cf873f52a04b15d32e132d8ecb5b175b5f542b37c5e299110f58a6"
		),
	]
)
