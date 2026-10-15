import ApiClientPrimitive
@_exported import AuthenticationFeaturePrimitive
import ComposableArchitecture
import LandingPagesFeature
import LoginFeature
import SwiftUI

@Reducer
public struct AuthenticationFeature {
	
	@Reducer
	public enum Path {
		case login(LoginFeature)
	}
	
	@ObservableState
	public struct State: Equatable {
		public var landingPages: LandingPagesFeature.State
		public var path: StackState<Path.State>
		
		public init(
			landingPages: LandingPagesFeature.State = .init(),
			path: StackState<Path.State> = .init()
		) {
			self.landingPages = landingPages
			self.path = path
		}
	}
	
	public enum Action {
		case landingPages(LandingPagesFeature.Action)
		case path(StackActionOf<Path>)
		case delegate(Delegate)
		
		@CasePathable
		public enum Delegate: Equatable {
			case didLogin(ApiClient.User)
		}
	}
	
	public init() {}
	
	public var body: some ReducerOf<Self> {
		Scope(state: \.landingPages, action: \.landingPages) {
			LandingPagesFeature()
		}
		Reduce { state, action in
			switch action {
				
			case .landingPages(.delegate(.loginTapped)):
				state.path.append(.login(.init()))
				return .none
				
			case let .path(.element(id: _, action: .login(.delegate(.didLogin(user))))):
				return .send(.delegate(.didLogin(user)))
				
			case .landingPages, .path, .delegate:
				return .none
			}
		}
		.forEach(\.path, action: \.path)
	}
}

extension AuthenticationFeature.Path.State: Equatable {}

// MARK: - SwiftUI

public struct AuthenticationView: View {
	@Bindable public var store: StoreOf<AuthenticationFeature>
	
	public init(store: StoreOf<AuthenticationFeature>) {
		self.store = store
	}
	
	public var body: some View {
		AuthenticationViewPrimitive {
			NavigationStack(path: $store.scope(
				state: \.path,
				action: \.path
			)) {
				LandingPagesView(store: store.scope(state: \.landingPages, action: \.landingPages))
			} destination: { store in
				switch store.case {
					
				case let .login(store):
					LoginView(store: store)
				}
			}
		}
	}
}

// MARK: - SwiftUI Previews

#Preview {
	AuthenticationView(store: Store(
		initialState: AuthenticationFeature.State()
	) {
		AuthenticationFeature()
	})
}
