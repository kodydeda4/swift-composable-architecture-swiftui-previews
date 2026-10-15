import ComposableArchitecture
import LandingPagesFeature
import Testing

@MainActor
struct LandingPagesFeatureTests {
	@Test
	func nextAdvancesUntilLastPage() async {
		let store = TestStore(initialState: LandingPagesFeature.State()) {
			LandingPagesFeature()
		}

		await store.send(.view(.nextButtonTapped)) {
			$0.view.selection = 1
		}
		await store.send(.view(.nextButtonTapped)) {
			$0.view.selection = 2
		}
		await store.send(.view(.nextButtonTapped))
	}

	@Test
	func swipeBindsSelection() async {
		let store = TestStore(initialState: LandingPagesFeature.State()) {
			LandingPagesFeature()
		}

		await store.send(.binding(.set(\.view.selection, 2))) {
			$0.view.selection = 2
		}
	}

	@Test
	func loginTapped() async {
		let store = TestStore(initialState: LandingPagesFeature.State()) {
			LandingPagesFeature()
		}

		await store.send(.view(.loginButtonTapped))
		await store.receive(\.delegate.loginTapped)
	}
}
