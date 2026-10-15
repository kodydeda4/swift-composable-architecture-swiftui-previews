import DesignSystem
import StorePrimitive
import SwiftUI

public enum SettingsFeaturePrimitive: Primitive.Reducer {
	public struct State: Equatable, Sendable {
		public var name: String
		
		public init(name: String = "") {
			self.name = name
		}
		
		public var isSaveButtonDisabled: Bool {
			name.isEmpty
		}
	}
	
	/// The text field binds directly to `State`, so only non-binding events are actions.
	public enum Action: Equatable, Sendable {
		case cancelButtonTapped
		case saveButtonTapped
	}
}

// MARK: - SwiftUI

public struct SettingsViewPrimitive: View, Primitive.ViewAction {
	@Primitive.Bindable public var store: Primitive.StoreOf<SettingsFeaturePrimitive>
	
	public init(store: Primitive.StoreOf<SettingsFeaturePrimitive>) {
		self.store = store
	}
	
	public var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: Theme.Spacing.xl) {
					Avatar(name: store.name, size: 88)
						.animation(.snappy, value: store.name)
					InputField("Name", systemImage: "person", text: $store.name)
						.autocorrectionDisabled()
				}
				.padding(Theme.Spacing.xl)
			}
			.navigationTitle("Settings")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") { send(.cancelButtonTapped) }
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") { send(.saveButtonTapped) }
						.disabled(store.isSaveButtonDisabled)
				}
			}
		}
		#if os(macOS)
		.frame(minWidth: 380, minHeight: 300)
		#endif
	}
}

// MARK: - SwiftUI Previews

#Preview {
	SettingsViewPrimitive(store: .preview(.init(name: "Blob")))
}
