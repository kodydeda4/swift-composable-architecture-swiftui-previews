import ApiClient
import AppFeature
import ComposableArchitecture
import Testing

@MainActor
struct AppFeatureTests {
	@Test
	func loginThenLogout() async {
		let store = TestStore(initialState: AppFeature.State()) {
			AppFeature()
		} withDependencies: {
			$0.apiClient.login = { _ in .init(user: .mock) }
			$0.apiClient.fetchPokemon = { _ in .init(pokemon: ApiClient.Pokemon.mocks) }
		}

		// Landing pages → push login.
		await store.send(\.authentication.landingPages.view, .loginButtonTapped)
		await store.receive(\.authentication.landingPages.delegate.loginTapped) {
			$0.modify(\.authentication) { $0.path[id: 0] = .login(.init()) }
		}

		// Fill in and submit the pushed login screen.
		await store.send(\.authentication.path[id: 0].login.binding, .set(\.view.email, "blob@pointfree.co")) {
			$0.modify(\.authentication) { $0.path[id: 0, case: \.login]?.view.email = "blob@pointfree.co" }
		}
		await store.send(\.authentication.path[id: 0].login.binding, .set(\.view.password, "password")) {
			$0.modify(\.authentication) { $0.path[id: 0, case: \.login]?.view.password = "password" }
		}
		await store.send(\.authentication.path[id: 0].login.view, .loginButtonTapped) {
			$0.modify(\.authentication) { $0.path[id: 0, case: \.login]?.view.isLoading = true }
		}
		await store.receive(\.authentication.path[id: 0].login.loginResponse.success) {
			$0.modify(\.authentication) { $0.path[id: 0, case: \.login]?.view.isLoading = false }
		}
		await store.receive(\.authentication.path[id: 0].login.delegate.didLogin)
		await store.receive(\.authentication.delegate.didLogin) {
			$0 = .main(.init(user: .mock))
		}

		// Main: the Pokédex tab loads, then log out from the account tab.
		await store.send(\.main.pokemonList.view, .task) {
			$0.modify(\.main) { $0.pokemonList.view.isLoading = true }
		}
		await store.receive(\.main.pokemonList.pokemonResponse.success) {
			$0.modify(\.main) {
				$0.pokemonList.view.isLoading = false
				$0.pokemonList.view.pokemon = ApiClient.Pokemon.mocks
			}
		}
		await store.send(\.main.binding, .set(\.view.selectedTab, .account)) {
			$0.modify(\.main) { $0.view.selectedTab = .account }
		}
		await store.send(\.main.view, .logoutButtonTapped)
		await store.receive(\.main.delegate.didLogout) {
			$0 = .authentication(.init())
		}
	}
}
