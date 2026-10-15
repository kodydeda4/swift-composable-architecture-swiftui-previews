// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "MainFeature",
	platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
	products: [
		.library(name: "MainFeaturePrimitive", targets: ["MainFeaturePrimitive"]),
		.library(name: "MainFeature", targets: ["MainFeature"]),
	],
	dependencies: [
		.package(path: "../DesignSystem"),
		.package(path: "../ApiClient"),
		.package(path: "../AppState"),
		.package(path: "../StorePrimitive"),
		.package(path: "../PokemonListFeature"),
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.0"),
	],
	targets: [
		// Vanilla. View, view state, view actions, previews. No TCA.
		.target(
			name: "MainFeaturePrimitive",
			dependencies: [
				.product(name: "DesignSystem", package: "DesignSystem"),
				.product(name: "ApiClientPrimitive", package: "ApiClient"),
				.product(name: "PokemonListFeaturePrimitive", package: "PokemonListFeature"),
				.product(name: "StorePrimitive", package: "StorePrimitive"),
			]
		),

		// TCA. Reducer + the view that connects a store to the vanilla view.
		.target(
			name: "MainFeature",
			dependencies: [
				"MainFeaturePrimitive",
				.product(name: "AppState", package: "AppState"),
				.product(name: "ApiClient", package: "ApiClient"),
				.product(name: "PokemonListFeature", package: "PokemonListFeature"),
				.product(name: "StorePrimitive", package: "StorePrimitive"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.testTarget(
			name: "MainFeatureTests",
			dependencies: [
				"MainFeature",
				.product(name: "ApiClient", package: "ApiClient"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
	]
)
