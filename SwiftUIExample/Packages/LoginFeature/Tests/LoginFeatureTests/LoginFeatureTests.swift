import ApiClient
import ComposableArchitecture
import Foundation
import LoginFeature
import Testing

@MainActor
struct LoginFeatureTests {
	@Test
	func loginSuccess() async {
		let store = TestStore(initialState: LoginFeature.State()) {
			LoginFeature()
		} withDependencies: {
			$0.apiClient.login = { _ in .init(user: .mock) }
		}

		await store.send(.binding(.set(\.view.email, "blob@pointfree.co"))) {
			$0.view.email = "blob@pointfree.co"
		}
		await store.send(.binding(.set(\.view.password, "password"))) {
			$0.view.password = "password"
		}
		await store.send(.view(.loginButtonTapped)) {
			$0.view.isLoading = true
		}
		await store.receive(\.loginResponse.success) {
			$0.view.isLoading = false
		}
		await store.receive(\.delegate.didLogin, .mock)
	}

	@Test
	func loginFailure() async {
		struct Failure: LocalizedError {
			var errorDescription: String? { "Invalid email or password." }
		}
		let store = TestStore(
			initialState: LoginFeature.State(view: .init(email: "blob@pointfree.co", password: "wrong"))
		) {
			LoginFeature()
		} withDependencies: {
			$0.apiClient.login = { _ in throw Failure() }
		}

		await store.send(.view(.loginButtonTapped)) {
			$0.view.isLoading = true
		}
		await store.receive(\.loginResponse.failure) {
			$0.view.isLoading = false
		}
		await store.send(.binding(.set(\.view.password, "password"))) {
			$0.view.password = "password"
		}
	}

	@Test
	func loginButtonIgnoredWhenFieldsEmpty() async {
		let store = TestStore(initialState: LoginFeature.State()) {
			LoginFeature()
		}

		await store.send(.view(.loginButtonTapped))
	}
}
