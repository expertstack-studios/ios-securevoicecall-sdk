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
			checksum: "5edb5c6b21c771edf07592f349b363560779aab4ebd0396264786f68f8c71e2b"
		),
	]
)
