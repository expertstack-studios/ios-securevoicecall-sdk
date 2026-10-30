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
		    url: "https://github.com/expertstack-studios/ios-securevoicecall-sdk/releases/download/1.1.0-rc.1/SecuredCallsVoiceSDK.xcframework.zip",
		    checksum: "69966f580a809b84686b3745f96a4978fc9c7fa59bf0fcdf746a39a9f2b1b3a7"
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
