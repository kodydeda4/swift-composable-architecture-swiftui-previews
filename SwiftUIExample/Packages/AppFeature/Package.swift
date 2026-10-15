// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "AppFeature",
	platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
	products: [
		.library(name: "AppFeaturePrimitive", targets: ["AppFeaturePrimitive"]),
		.library(name: "AppFeature", targets: ["AppFeature"]),
	],
	dependencies: [
		.package(path: "../DesignSystem"),
		.package(path: "../ApiClient"),
		.package(path: "../AppState"),
		.package(path: "../AuthenticationFeature"),
		.package(path: "../LandingPagesFeature"),
		.package(path: "../MainFeature"),
		.package(path: "../PokemonListFeature"),
		.package(path: "../StorePrimitive"),
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.0"),
	],
	targets: [
		// Vanilla. Root container view. Children are passed in as views, so it can be
		// previewed with the vanilla child views and run with the TCA-connected ones.
		.target(
			name: "AppFeaturePrimitive",
			dependencies: [
				.product(name: "DesignSystem", package: "DesignSystem"),
				.product(name: "AuthenticationFeaturePrimitive", package: "AuthenticationFeature"),
				.product(name: "LandingPagesFeaturePrimitive", package: "LandingPagesFeature"),
				.product(name: "MainFeaturePrimitive", package: "MainFeature"),
				.product(name: "PokemonListFeaturePrimitive", package: "PokemonListFeature"),
				.product(name: "StorePrimitive", package: "StorePrimitive"),
			]
		),

		// TCA. Switches the root between authentication and main.
		.target(
			name: "AppFeature",
			dependencies: [
				"AppFeaturePrimitive",
				.product(name: "ApiClient", package: "ApiClient"),
				.product(name: "AppState", package: "AppState"),
				.product(name: "AuthenticationFeature", package: "AuthenticationFeature"),
				.product(name: "MainFeature", package: "MainFeature"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.testTarget(
			name: "AppFeatureTests",
			dependencies: [
				"AppFeature",
				.product(name: "ApiClient", package: "ApiClient"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
	]
)
