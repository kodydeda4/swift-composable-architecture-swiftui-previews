@_exported import ApiClientPrimitive
import Dependencies

// MARK: - Upgrades the vanilla interface to a TCA dependency.
// `liveValue` is deliberately NOT here. It lives in `ApiClientLive`, so features
// and their tests can use `@Dependency(\.apiClient)` without compiling third party SDKs.

extension ApiClient: TestDependencyKey {
	public static let testValue = Self(
		login: unimplemented("ApiClient.login"),
		fetchPokemon: unimplemented("ApiClient.fetchPokemon")
	)

	public static let previewValue = Self.mock
}

extension DependencyValues {
	public var apiClient: ApiClient {
		get { self[ApiClient.self] }
		set { self[ApiClient.self] = newValue }
	}
}
