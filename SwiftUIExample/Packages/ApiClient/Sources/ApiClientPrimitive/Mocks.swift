import Foundation

// MARK: - Mock data. Shared by vanilla previews, TCA preview values and tests.

extension ApiClient.User {
	public static let mock = Self(id: 1, name: "Blob", email: "blob@pointfree.co")
}

extension ApiClient.Pokemon {
	public static let mocks: [Self] = [
		Self(id: 1, name: "bulbasaur"),
		Self(id: 4, name: "charmander"),
		Self(id: 7, name: "squirtle"),
		Self(id: 25, name: "pikachu"),
	]
}

extension ApiClient {
	public static let mock = Self(
		login: { _ in
			try await Task.sleep(for: .milliseconds(500))
			return .init(user: .mock)
		},
		fetchPokemon: { _ in
			try await Task.sleep(for: .milliseconds(500))
			return .init(pokemon: Pokemon.mocks)
		}
	)
}
