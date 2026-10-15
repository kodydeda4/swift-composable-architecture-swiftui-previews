// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "PokemonListFeature",
	platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
	products: [
		.library(name: "PokemonListFeaturePrimitive", targets: ["PokemonListFeaturePrimitive"]),
		.library(name: "PokemonListFeature", targets: ["PokemonListFeature"]),
	],
	dependencies: [
		.package(path: "../DesignSystem"),
		.package(path: "../ApiClient"),
		.package(path: "../AppState"),
		.package(path: "../PokemonDetailsFeature"),
		.package(path: "../SettingsFeature"),
		.package(path: "../StorePrimitive"),
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.0"),
	],
	targets: [
		// Vanilla. View, view state, view actions, previews. No TCA.
		.target(
			name: "PokemonListFeaturePrimitive",
			dependencies: [
				.product(name: "DesignSystem", package: "DesignSystem"),
				.product(name: "ApiClientPrimitive", package: "ApiClient"),
				.product(name: "StorePrimitive", package: "StorePrimitive"),
			]
		),

		// TCA. Reducer + the view that connects a store to the vanilla view.
		.target(
			name: "PokemonListFeature",
			dependencies: [
				"PokemonListFeaturePrimitive",
				.product(name: "AppState", package: "AppState"),
				.product(name: "ApiClient", package: "ApiClient"),
				.product(name: "PokemonDetailsFeature", package: "PokemonDetailsFeature"),
				.product(name: "SettingsFeature", package: "SettingsFeature"),
				.product(name: "StorePrimitive", package: "StorePrimitive"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.testTarget(
			name: "PokemonListFeatureTests",
			dependencies: [
				"PokemonListFeature",
				.product(name: "ApiClient", package: "ApiClient"),
				.product(name: "SettingsFeature", package: "SettingsFeature"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
	]
)
