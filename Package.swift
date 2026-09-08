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
			type: .static,
			targets: ["SecuredCallsVoiceSDKWrapper"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/Vonage/vonage-client-sdk-ios", from: "2.1.3")
	],
	targets: [
		.binaryTarget(
		    name: "SecuredCallsVoiceSDKBinary",
		    url: "https://github.com/expertstack-studios/ios-securevoicecall-sdk/releases/download/1.0.27-rc.3/SecuredCallsVoiceSDK.xcframework.zip",
		    checksum: "2f4dd38b1ff040ab8dda3d881809735ddadc0a89ac947bd93526629e6e87992e"
		),
		.target(
			name: "SecuredCallsVoiceSDKWrapper",
			dependencies: [
				"SecuredCallsVoiceSDKBinary",
				.product(name: "VonageClientSDK", package: "vonage-client-sdk-ios"),
				.product(name: "VonageClientSDKVoice", package: "vonage-client-sdk-ios")
			],
			path: "./Sources/SecuredCallsVoiceSDKWrapper",
			resources: [], // Explicitly no resources
			swiftSettings: [
				.enableExperimentalFeature("AccessLevelOnImport")
			]
		)
	]
)
