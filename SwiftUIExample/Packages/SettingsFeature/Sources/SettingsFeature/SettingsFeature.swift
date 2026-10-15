import ComposableArchitecture
@_exported import SettingsFeaturePrimitive
import StorePrimitive
import SwiftUI

@Reducer
public struct SettingsFeature {
	
	@ObservableState
	public struct State: Equatable {
		public var view: Self.View
		
		public init(view: Self.View = .init()) {
			self.view = view
		}
		
		public init(name: String) {
			self.init(view: .init(name: name))
		}
	}
	
	public enum Action: BindableAction, ViewAction {
		case view(Self.View)
		case binding(BindingAction<State>)
		case delegate(Delegate)
		
		@CasePathable
		public enum Delegate: Equatable {
			case didSave(name: String)
		}
	}
	
	@Dependency(\.dismiss) var dismiss
	
	public init() {}
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
				
			case .binding, .delegate:
				return .none
				
			case let .view(action):
				switch action {
					
				case .cancelButtonTapped:
					return .run { [dismiss] _ in await dismiss() }
					
				case .saveButtonTapped:
					return .run { [dismiss, name = state.view.name] send in
						await send(.delegate(.didSave(name: name)))
						await dismiss()
					}
				}
			}
		}
	}
}

extension SettingsFeature.State { public typealias View = SettingsFeaturePrimitive.State }
extension SettingsFeature.Action { public typealias View = SettingsFeaturePrimitive.Action }

// MARK: - SwiftUI

@ViewAction(for: SettingsFeature.self)
public struct SettingsView: View {
	@Bindable public var store: StoreOf<SettingsFeature>
	
	public init(store: StoreOf<SettingsFeature>) {
		self.store = store
	}
	
	public var body: some View {
		SettingsViewPrimitive(store: Primitive.Store(
			state: $store.view,
			action: { send($0) }
		))
	}
}

// MARK: - SwiftUI Previews

#Preview {
	SettingsView(store: Store(
		initialState: SettingsFeature.State(name: "Blob")
	) {
		SettingsFeature()
	})
}
