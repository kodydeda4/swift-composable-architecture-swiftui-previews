import ApiClient
import ComposableArchitecture
import MainFeature
import Testing

@MainActor
struct MainFeatureTests {
	@Test
	func selectTab() async {
		let store = TestStore(initialState: MainFeature.State(user: .mock)) {
			MainFeature()
		}

		await store.send(.binding(.set(\.view.selectedTab, .account))) {
			$0.view.selectedTab = .account
		}
	}

	@Test
	func pokemonLoadThroughChild() async {
		let store = TestStore(initialState: MainFeature.State(user: .mock)) {
			MainFeature()
		} withDependencies: {
			$0.apiClient.fetchPokemon = { _ in .init(pokemon: ApiClient.Pokemon.mocks) }
		}

		await store.send(\.pokemonList.view, .task) {
			$0.pokemonList.view.isLoading = true
		}
		await store.receive(\.pokemonList.pokemonResponse.success) {
			$0.pokemonList.view.isLoading = false
			$0.pokemonList.view.pokemon = ApiClient.Pokemon.mocks
		}
	}

	@Test
	func logout() async {
		let store = TestStore(initialState: MainFeature.State(user: .mock)) {
			MainFeature()
		}

		await store.send(.view(.logoutButtonTapped))
		await store.receive(\.delegate.didLogout)
	}
}
