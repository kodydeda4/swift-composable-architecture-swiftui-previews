// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "LoginFeature",
	platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
	products: [
		.library(name: "LoginFeaturePrimitive", targets: ["LoginFeaturePrimitive"]),
		.library(name: "LoginFeature", targets: ["LoginFeature"]),
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
			name: "LoginFeaturePrimitive",
			dependencies: [
				.product(name: "DesignSystem", package: "DesignSystem"),
				.product(name: "ApiClientPrimitive", package: "ApiClient"),
				.product(name: "StorePrimitive", package: "StorePrimitive"),
			]
		),

		// TCA. Reducer + the view that connects a store to the vanilla view.
		.target(
			name: "LoginFeature",
			dependencies: [
				"LoginFeaturePrimitive",
				.product(name: "ApiClient", package: "ApiClient"),
				.product(name: "StorePrimitive", package: "StorePrimitive"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.testTarget(
			name: "LoginFeatureTests",
			dependencies: [
				"LoginFeature",
				.product(name: "ApiClient", package: "ApiClient"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
	]
)
