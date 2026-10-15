import Foundation

// MARK: - Dependency Interface. NO THIRD PARTY.

public struct ApiClient: Sendable {
	public var login: @Sendable (Login.Request) async throws -> Login.Response
	public var fetchPokemon: @Sendable (FetchPokemon.Request) async throws -> FetchPokemon.Response

	public init(
		login: @escaping @Sendable (Login.Request) async throws -> Login.Response,
		fetchPokemon: @escaping @Sendable (FetchPokemon.Request) async throws -> FetchPokemon.Response
	) {
		self.login = login
		self.fetchPokemon = fetchPokemon
	}
}

// MARK: - Endpoints

extension ApiClient {
	public enum Login {
		public struct Request: Equatable, Sendable {
			public var email: String
			public var password: String

			public init(email: String, password: String) {
				self.email = email
				self.password = password
			}
		}

		public struct Response: Equatable, Sendable {
			public var user: User

			public init(user: User) {
				self.user = user
			}
		}
	}

	public enum FetchPokemon {
		public struct Request: Equatable, Sendable {
			public var limit: Int

			public init(limit: Int = 151) {
				self.limit = limit
			}
		}

		public struct Response: Equatable, Sendable {
			public var pokemon: [Pokemon]

			public init(pokemon: [Pokemon]) {
				self.pokemon = pokemon
			}
		}
	}
}

// MARK: - Models

extension ApiClient {
	public struct User: Equatable, Identifiable, Sendable {
		public let id: Int
		public var name: String
		public var email: String

		public init(id: Int, name: String, email: String) {
			self.id = id
			self.name = name
			self.email = email
		}
	}

	public struct Pokemon: Equatable, Identifiable, Sendable {
		public let id: Int
		public var name: String

		public init(id: Int, name: String) {
			self.id = id
			self.name = name
		}

		public var spriteURL: URL {
			URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")!
		}
	}
}
