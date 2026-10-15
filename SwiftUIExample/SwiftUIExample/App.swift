import ApiClient
import ApiClientLive
import AppFeature
import ComposableArchitecture
import SwiftUI

@main
struct _App: App {
	static let store = Store(initialState: AppFeature.State()) {
		AppFeature()
	} withDependencies: {
		$0.apiClient = .liveValue
	}

	var body: some Scene {
		WindowGroup {
			AppView(store: Self.store)
		}
	}
}
