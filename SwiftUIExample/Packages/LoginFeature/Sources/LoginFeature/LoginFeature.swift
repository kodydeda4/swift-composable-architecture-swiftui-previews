import ApiClient
import ComposableArchitecture
@_exported import LoginFeaturePrimitive
import StorePrimitive
import SwiftUI

@Reducer
public struct LoginFeature {
	
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
		case loginResponse(Result<ApiClient.Login.Response, any Error>)
		
		@CasePathable
		public enum Delegate: Equatable {
			case didLogin(ApiClient.User)
		}
	}
	
	@Dependency(\.apiClient) var apiClient
	
	public init() {}
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
				
			case .binding, .delegate:
				return .none
				
			case let .loginResponse(.success(response)):
				state.view.isLoading = false
				return .send(.delegate(.didLogin(response.user)))
				
			case .loginResponse(.failure):
				state.view.isLoading = false
				return .none
				
			case let .view(action):
				switch action {
					
				case .loginButtonTapped:
					state.view.isLoading = true
					let request = ApiClient.Login.Request(email: state.view.email, password: state.view.password)
					return .run { [apiClient] send in
						await send(.loginResponse(.success(try await apiClient.login(request))))
					} catch: { error, send in
						await send(.loginResponse(.failure(error)))
					}
				}
			}
		}
	}
}

extension LoginFeature.State {
	public typealias View = LoginFeaturePrimitive.State
}

extension LoginFeature.Action {
	public typealias View = LoginFeaturePrimitive.Action
}

// MARK: - SwiftUI

@ViewAction(for: LoginFeature.self)
public struct LoginView: View {
	@Bindable public var store: StoreOf<LoginFeature>
	
	public init(store: StoreOf<LoginFeature>) {
		self.store = store
	}
	
	public var body: some View {
		LoginViewPrimitive(store: StorePrimitive(
			state: $store.view,
			action: { send($0) }
		))
	}
}

// MARK: - SwiftUI Previews

#Preview {
	NavigationStack {
		LoginView(store: Store(
			initialState: LoginFeature.State()
		) {
			LoginFeature()
		})
	}
}
