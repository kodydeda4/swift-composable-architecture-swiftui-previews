// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "ApiClient",
	platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
	products: [
		.library(name: "ApiClientPrimitive", targets: ["ApiClientPrimitive"]),
		.library(name: "ApiClient", targets: ["ApiClient"]),
		.library(name: "ApiClientLive", targets: ["ApiClientLive"]),
	],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.4.0"),
		.package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "2.1.1"),
	],
	targets: [
		// Vanilla. Models, the client interface and mock data. No third party.
		// Feature `*Primitive` targets (and their previews) depend only on this.
		.target(name: "ApiClientPrimitive"),

		// Upgrades the vanilla interface into a `@Dependency` (test + preview values).
		// Only needs swift-dependencies, not the whole of TCA.
		.target(
			name: "ApiClient",
			dependencies: [
				"ApiClientPrimitive",
				.product(name: "Dependencies", package: "swift-dependencies"),
			]
		),

		// The real implementation. Third party SDKs (AWS, Firebase, ...) go here and
		// only here. Linked by the app target, never by features or their tests.
		.target(
			name: "ApiClientLive",
			dependencies: [
				"ApiClient",
				.product(name: "SwiftyBeaver", package: "SwiftyBeaver"),
			]
		),
	]
)
