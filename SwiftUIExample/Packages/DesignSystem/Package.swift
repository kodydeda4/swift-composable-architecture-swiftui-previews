// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "DesignSystem",
	platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
	products: [
		.library(name: "DesignSystem", targets: ["DesignSystem"]),
	],
	targets: [
		// Vanilla. Colors, button styles and reusable components. SwiftUI only.
		.target(name: "DesignSystem"),
	]
)
