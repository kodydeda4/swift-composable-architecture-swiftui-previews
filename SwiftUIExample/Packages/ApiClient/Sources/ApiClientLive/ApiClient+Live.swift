import ApiClient
import Dependencies
import Foundation
import SwiftyBeaver

// MARK: - Dependency implementation. Imports external libraries and implements interfaces.
// This is the only target allowed to import third party SDKs (AWS, Firebase, ...).
// Here it talks to pokeapi.co with plain URLSession.

extension ApiClient: DependencyKey {
	public static let liveValue: Self = {
		let baseURL = URL(string: "https://pokeapi.co/api/v2")!

		return Self(
			login: { request in
				// No real auth: any non-empty email and password logs in as user 1.
				log.info("→ login \(request.email)")
				guard !request.email.isEmpty, !request.password.isEmpty else {
					log.error("← login failed: \(LoginError.invalidCredentials.localizedDescription)")
					throw LoginError.invalidCredentials
				}
				let name = request.email.split(separator: "@").first.map(String.init) ?? request.email
				log.info("← login succeeded as \(name)")
				return .init(user: .init(id: 1, name: name, email: request.email))
			},
			fetchPokemon: { request in
				let url = baseURL
					.appending(path: "pokemon")
					.appending(queryItems: [URLQueryItem(name: "limit", value: "\(request.limit)")])
				let page: PokemonPageDTO = try await get(url)
				return .init(pokemon: page.results.compactMap { result in
					// The id is the last path component of `url`, e.g. ".../pokemon/25/".
					guard let id = Int(result.url.lastPathComponent) else { return nil }
					return .init(id: id, name: result.name)
				})
			}
		)
	}()
}

public enum LoginError: LocalizedError {
	case invalidCredentials

	public var errorDescription: String? { "Invalid email or password." }
}

// MARK: - Logging. Every request logs when it starts and how it finished.

private let log: SwiftyBeaver.Type = {
	SwiftyBeaver.addDestination(ConsoleDestination())
	return SwiftyBeaver.self
}()

// MARK: - Wire types. Kept private so the vanilla models stay decoupled from the server.

private struct PokemonPageDTO: Decodable {
	struct Result: Decodable {
		let name: String
		let url: URL
	}

	let results: [Result]
}

private func get<T: Decodable>(_ url: URL) async throws -> T {
	log.info("→ GET \(url.absoluteString)")
	let start = ContinuousClock.now
	do {
		let (data, response) = try await URLSession.shared.data(from: url)
		let elapsed = ContinuousClock.now - start
		guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
			let status = (response as? HTTPURLResponse)?.statusCode ?? -1
			throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "HTTP \(status) after \(elapsed)"])
		}
		log.info("← \(http.statusCode) GET \(url.absoluteString) (\(elapsed), \(data.count) bytes)")
		return try JSONDecoder().decode(T.self, from: data)
	} catch {
		log.error("✕ GET \(url.absoluteString): \(error.localizedDescription)")
		throw error
	}
}
