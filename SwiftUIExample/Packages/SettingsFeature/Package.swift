// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "SettingsFeature",
	platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
	products: [
		.library(name: "SettingsFeaturePrimitive", targets: ["SettingsFeaturePrimitive"]),
		.library(name: "SettingsFeature", targets: ["SettingsFeature"]),
	],
	dependencies: [
		.package(path: "../DesignSystem"),
		.package(path: "../StorePrimitive"),
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.0"),
	],
	targets: [
		// Vanilla. View, view state, view actions, previews. No TCA.
		.target(
			name: "SettingsFeaturePrimitive",
			dependencies: [
				.product(name: "DesignSystem", package: "DesignSystem"),
				.product(name: "StorePrimitive", package: "StorePrimitive"),
			]
		),

		// TCA. Reducer + the view that connects a store to the vanilla view.
		.target(
			name: "SettingsFeature",
			dependencies: [
				"SettingsFeaturePrimitive",
				.product(name: "StorePrimitive", package: "StorePrimitive"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.testTarget(
			name: "SettingsFeatureTests",
			dependencies: [
				"SettingsFeature",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
	]
)
