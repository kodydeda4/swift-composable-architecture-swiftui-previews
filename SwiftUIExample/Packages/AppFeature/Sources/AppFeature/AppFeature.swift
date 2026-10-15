import ApiClient
@_exported import AppFeaturePrimitive
import AppState
import AuthenticationFeature
import ComposableArchitecture
import MainFeature
import SwiftUI

@Reducer
public struct AppFeature {
	
	@Reducer
	public enum Destination {
		case authentication(AuthenticationFeature)
		case main(MainFeature)
	}
	
	@ObservableState
	public struct State: Equatable {
		@Presents public var destination: Destination.State? = .authentication(.init())
		@Shared(.user) public var user
		
		public init() {}
	}
	
	public enum Action {
		case destination(PresentationAction<Destination.Action>)
	}
	
	public init() {}
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				
			case let .destination(.presented(.authentication(.delegate(.didLogin(user))))):
				state.$user.withLock { $0 = user }
				guard let user = Shared(state.$user) else { return .none }
				state.destination = .main(.init(user: user))
				return .none
				
			case .destination(.presented(.main(.delegate(.didLogout)))):
				state.destination = .authentication(.init())
				state.$user.withLock { $0 = nil }
				return .none
				
			case .destination:
				return .none
			}
		}
		.ifLet(\.$destination, action: \.destination)
	}
}

extension AppFeature.Destination.State: Equatable {}

// MARK: - SwiftUI

public struct AppView: View {
	@Bindable public var store: StoreOf<AppFeature>
	
	public init(store: StoreOf<AppFeature>) {
		self.store = store
	}
	
	public var body: some View {
		AppViewPrimitive(destination: self.destination())
	}
	
	func destination() -> AppViewPrimitive<AuthenticationView, MainView>.Destination? {
		switch self.store.scope(state: \.destination, action: \.destination.presented)?.case {
			
		case let .authentication(store):
			.authentication(AuthenticationView(store: store))
			
		case let .main(store):
			.main(MainView(store: store))
			
		case .none:
			nil
		}
	}
}

// MARK: - SwiftUI Previews

#Preview {
	AppView(store: Store(
		initialState: AppFeature.State()
	) {
		AppFeature()
	})
}
