// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "AuthenticationFeature",
	platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
	products: [
		.library(name: "AuthenticationFeaturePrimitive", targets: ["AuthenticationFeaturePrimitive"]),
		.library(name: "AuthenticationFeature", targets: ["AuthenticationFeature"]),
	],
	dependencies: [
		.package(path: "../DesignSystem"),
		.package(path: "../ApiClient"),
		.package(path: "../StorePrimitive"),
		.package(path: "../LandingPagesFeature"),
		.package(path: "../LoginFeature"),
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.0"),
	],
	targets: [
		// Vanilla. View, view state, view actions, previews. No TCA.
		.target(
			name: "AuthenticationFeaturePrimitive",
			dependencies: [
				.product(name: "DesignSystem", package: "DesignSystem"),
				.product(name: "LandingPagesFeaturePrimitive", package: "LandingPagesFeature"),
				.product(name: "ApiClientPrimitive", package: "ApiClient"),
				.product(name: "LoginFeaturePrimitive", package: "LoginFeature"),
				.product(name: "StorePrimitive", package: "StorePrimitive"),
			]
		),

		// TCA. Reducer + the view that connects a store to the vanilla view.
		.target(
			name: "AuthenticationFeature",
			dependencies: [
				"AuthenticationFeaturePrimitive",
				.product(name: "ApiClientPrimitive", package: "ApiClient"),
				.product(name: "LandingPagesFeature", package: "LandingPagesFeature"),
				.product(name: "LoginFeature", package: "LoginFeature"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.testTarget(
			name: "AuthenticationFeatureTests",
			dependencies: [
				"AuthenticationFeature",
				.product(name: "ApiClient", package: "ApiClient"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
	]
)
