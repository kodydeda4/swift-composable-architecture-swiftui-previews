// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "AppState",
	platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
	products: [
		.library(name: "AppState", targets: ["AppState"]),
	],
	dependencies: [
		.package(path: "../ApiClient"),
		.package(url: "https://github.com/pointfreeco/swift-sharing", from: "2.0.0"),
	],
	targets: [
		// `@Shared` keys. Features read and write app-wide state through these.
		.target(
			name: "AppState",
			dependencies: [
				.product(name: "ApiClientPrimitive", package: "ApiClient"),
				.product(name: "Sharing", package: "swift-sharing"),
			]
		),
	]
)
