import ApiClient
import ComposableArchitecture
import Foundation
import PokemonListFeature
import SettingsFeature
import Testing

@MainActor
struct PokemonListFeatureTests {
	@Test
	func fetchOnAppear() async {
		let store = TestStore(initialState: PokemonListFeature.State(user: .mock)) {
			PokemonListFeature()
		} withDependencies: {
			$0.apiClient.fetchPokemon = { _ in .init(pokemon: ApiClient.Pokemon.mocks) }
		}

		await store.send(.view(.task)) {
			$0.view.isLoading = true
		}
		await store.receive(\.pokemonResponse.success) {
			$0.view.isLoading = false
			$0.view.pokemon = ApiClient.Pokemon.mocks
		}
		// Already loaded: re-appearing doesn't refetch.
		await store.send(.view(.task))
	}

	@Test
	func fetchFailure() async {
		let store = TestStore(initialState: PokemonListFeature.State(user: .mock)) {
			PokemonListFeature()
		} withDependencies: {
			$0.apiClient.fetchPokemon = { _ in throw URLError(.notConnectedToInternet) }
		}

		await store.send(.view(.task)) {
			$0.view.isLoading = true
		}
		await store.receive(\.pokemonResponse.failure) {
			$0.view.isLoading = false
		}
	}

	@Test
	func favoriteToggles() async {
		let store = TestStore(
			initialState: PokemonListFeature.State(view: .init(user: .mock, pokemon: ApiClient.Pokemon.mocks))
		) {
			PokemonListFeature()
		}

		await store.send(.view(.favoriteTapped(id: 25))) {
			$0.view.pokemon[3].isFavorite = true
		}
	}

	@Test
	func settingsSaveRenamesUser() async {
		let store = TestStore(initialState: PokemonListFeature.State(user: .mock)) {
			PokemonListFeature()
		}

		await store.send(.view(.settingsButtonTapped)) {
			$0.destination = .settings(.init(name: "Blob"))
		}
		await store.send(.destination(.presented(.settings(.binding(.set(\.view.name, "Blob Jr")))))) {
			$0.destination?.modify(\.settings) { $0.view.name = "Blob Jr" }
		}
		await store.send(.destination(.presented(.settings(.view(.saveButtonTapped)))))
		await store.receive(\.destination.presented.settings.delegate.didSave) {
			$0.view.user.name = "Blob Jr"
		}
		await store.receive(\.destination.dismiss) {
			$0.destination = nil
		}
	}
}
