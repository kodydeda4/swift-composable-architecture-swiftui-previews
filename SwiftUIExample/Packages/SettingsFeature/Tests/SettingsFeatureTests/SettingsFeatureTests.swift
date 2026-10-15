import ComposableArchitecture
import SettingsFeature
import Testing

@MainActor
struct SettingsFeatureTests {
	@Test
	func saveNonEmptyName() async {
		let isDismissed = LockIsolated(false)
		let store = TestStore(initialState: SettingsFeature.State(name: "Blob")) {
			SettingsFeature()
		} withDependencies: {
			$0.dismiss = DismissEffect { isDismissed.setValue(true) }
		}

		await store.send(.binding(.set(\.view.name, "Blob Jr"))) {
			$0.view.name = "Blob Jr"
		}
		await store.send(.view(.saveButtonTapped))
		await store.receive(\.delegate.didSave)
		#expect(isDismissed.value)
	}

	@Test
	func saveEmptyNameDoesNothing() async {
		let store = TestStore(initialState: SettingsFeature.State(name: "")) {
			SettingsFeature()
		}

		await store.send(.view(.saveButtonTapped))
	}

	@Test
	func cancelDismisses() async {
		let isDismissed = LockIsolated(false)
		let store = TestStore(initialState: SettingsFeature.State(name: "Blob")) {
			SettingsFeature()
		} withDependencies: {
			$0.dismiss = DismissEffect { isDismissed.setValue(true) }
		}

		await store.send(.view(.cancelButtonTapped))
		#expect(isDismissed.value)
	}
}
