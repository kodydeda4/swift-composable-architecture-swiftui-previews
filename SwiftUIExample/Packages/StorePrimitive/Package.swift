// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "StorePrimitive",
	platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
	products: [
		.library(name: "StorePrimitive", targets: ["StorePrimitive"]),
	],
	targets: [
		.target(name: "StorePrimitive"),
	]
)
