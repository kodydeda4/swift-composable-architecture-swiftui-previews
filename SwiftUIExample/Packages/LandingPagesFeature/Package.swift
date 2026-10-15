// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "LandingPagesFeature",
	platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
	products: [
		.library(name: "LandingPagesFeaturePrimitive", targets: ["LandingPagesFeaturePrimitive"]),
		.library(name: "LandingPagesFeature", targets: ["LandingPagesFeature"]),
	],
	dependencies: [
		.package(path: "../DesignSystem"),
		.package(path: "../ApiClient"),
		.package(path: "../StorePrimitive"),
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.0"),
	],
	targets: [
		// Vanilla. View, view state, view actions, previews. No TCA.
		.target(
			name: "LandingPagesFeaturePrimitive",
			dependencies: [
				.product(name: "DesignSystem", package: "DesignSystem"),
				.product(name: "StorePrimitive", package: "StorePrimitive"),
			]
		),

		// TCA. Reducer + the view that connects a store to the vanilla view.
		.target(
			name: "LandingPagesFeature",
			dependencies: [
				"LandingPagesFeaturePrimitive",
				.product(name: "StorePrimitive", package: "StorePrimitive"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.testTarget(
			name: "LandingPagesFeatureTests",
			dependencies: [
				"LandingPagesFeature",
				.product(name: "ApiClient", package: "ApiClient"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
	]
)
