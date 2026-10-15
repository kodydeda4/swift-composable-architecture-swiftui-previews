import ApiClient
import AuthenticationFeature
import ComposableArchitecture
import Testing

@MainActor
struct AuthenticationFeatureTests {
	@Test
	func loginTappedPushesLogin() async {
		let store = TestStore(initialState: AuthenticationFeature.State()) {
			AuthenticationFeature()
		}

		await store.send(\.landingPages.view, .loginButtonTapped)
		await store.receive(\.landingPages.delegate.loginTapped) {
			$0.path[id: 0] = .login(.init())
		}
	}

	@Test
	func loginSuccessDelegates() async {
		let store = TestStore(
			initialState: AuthenticationFeature.State(
				path: StackState([.login(.init(view: .init(email: "blob@pointfree.co", password: "password")))])
			)
		) {
			AuthenticationFeature()
		} withDependencies: {
			$0.apiClient.login = { _ in .init(user: .mock) }
		}

		await store.send(\.path[id: 0].login.view, .loginButtonTapped) {
			$0.path[id: 0, case: \.login]?.view.isLoading = true
		}
		await store.receive(\.path[id: 0].login.loginResponse.success) {
			$0.path[id: 0, case: \.login]?.view.isLoading = false
		}
		await store.receive(\.path[id: 0].login.delegate.didLogin)
		await store.receive(\.delegate.didLogin, .mock)
	}
}
