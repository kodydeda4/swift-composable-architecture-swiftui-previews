import ApiClientPrimitive
import Foundation
import Sharing

// MARK: - InMemory

extension SharedKey where Self == InMemoryKey<ApiClient.User?>.Default {
	/// The logged in user. `nil` while logged out.
	public static var user: Self {
		Self[.inMemory("user"), default: nil]
	}
}

// MARK: - FileStorage

extension SharedKey where Self == FileStorageKey<Set<ApiClient.Pokemon.ID>>.Default {
	/// The Pokémon the user has starred. Survives relaunches.
	public static var favoritePokemonIDs: Self {
		Self[.fileStorage(.sharing("favoritePokemonIDs")), default: []]
	}
}

// MARK: - Helpers

extension URL {
	/// Where a file-stored `@Shared` value named `name` lives.
	public static func sharing(_ name: String) -> URL {
		.documentsDirectory.appending(component: "\(name).json")
	}
}
