import ComposableArchitecture
@_exported import LandingPagesFeaturePrimitive
import StorePrimitive
import SwiftUI

@Reducer
public struct LandingPagesFeature {
	
	@ObservableState
	public struct State: Equatable {
		public var view: Self.View
		
		public init(view: Self.View = .init()) {
			self.view = view
		}
	}
	
	public enum Action: BindableAction, ViewAction {
		case view(Self.View)
		case binding(BindingAction<State>)
		case delegate(Delegate)
		
		@CasePathable
		public enum Delegate: Equatable {
			case loginTapped
		}
	}
	
	public init() {}
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
				
			case .binding, .delegate:
				return .none
				
			case let .view(action):
				switch action {
					
				case .nextButtonTapped:
					state.view.selection += 1
					return .none
					
				case .loginButtonTapped:
					return .send(.delegate(.loginTapped))
				}
			}
		}
	}
}

extension LandingPagesFeature.State {
	public typealias View = LandingPagesFeaturePrimitive.State
}

extension LandingPagesFeature.Action {
	public typealias View = LandingPagesFeaturePrimitive.Action
}

// MARK: - SwiftUI

@ViewAction(for: LandingPagesFeature.self)
public struct LandingPagesView: View {
	@Bindable public var store: StoreOf<LandingPagesFeature>
	
	public init(store: StoreOf<LandingPagesFeature>) {
		self.store = store
	}
	
	public var body: some View {
		LandingPagesViewPrimitive(store: Primitive.Store(
			state: $store.view,
			action: { send($0) }
		))
	}
}

// MARK: - SwiftUI Previews

#Preview {
	LandingPagesView(store: Store(
		initialState: LandingPagesFeature.State()
	) {
		LandingPagesFeature()
	})
}
