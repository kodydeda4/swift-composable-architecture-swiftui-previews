import ApiClient
import AppState
import ComposableArchitecture
@_exported import MainFeaturePrimitive
import StorePrimitive
import SwiftUI
import PokemonListFeature

@Reducer
public struct MainFeature {
	
	@ObservableState
	public struct State: Equatable {
		@Presents public var alert: AlertState<Action.Alert>? = nil
		@Shared public var user: ApiClient.User
		public var selectedTab: MainFeaturePrimitive.Tab = .pokemonList
		public var pokemonList: PokemonListFeature.State
		
		public init(user: Shared<ApiClient.User>) {
			self._user = user
			self.pokemonList = .init(user: user)
		}
		
		public var view: Self.View {
			get { .init(user: user, selectedTab: selectedTab) }
			set { selectedTab = newValue.selectedTab }
		}
	}
	
	public enum Action: BindableAction, ViewAction {
		case view(Self.View)
		case binding(BindingAction<State>)
		case alert(PresentationAction<Alert>)
		case delegate(Delegate)
		case pokemonList(PokemonListFeature.Action)
		
		@CasePathable
		public enum Alert: Equatable {
			case confirmLogoutButtonTapped
		}
		
		@CasePathable
		public enum Delegate: Equatable {
			case didLogout
		}
	}
	
	public init() {}
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.pokemonList, action: \.pokemonList) {
			PokemonListFeature()
		}
		Reduce { state, action in
			switch action {
				
			case .alert(.presented(.confirmLogoutButtonTapped)):
				return .send(.delegate(.didLogout))
				
			case .alert, .binding, .delegate, .pokemonList:
				return .none
				
			case let .view(action):
				switch action {
					
				case .logoutButtonTapped:
					state.alert = .logout
					return .none
				}
			}
		}
		.ifLet(\.$alert, action: \.alert)
	}
}

extension AlertState where Action == MainFeature.Action.Alert {
	static var logout: Self {
		Self {
			TextState("Log out?")
		} actions: {
			ButtonState(role: .destructive, action: .confirmLogoutButtonTapped) {
				TextState("Log out")
			}
			ButtonState(role: .cancel) {
				TextState("Cancel")
			}
		} message: {
			TextState("You'll need to log in again to see your Pokédex.")
		}
	}
}

extension MainFeature.State {
	public typealias View = MainFeaturePrimitive.State
}

extension MainFeature.Action {
	public typealias View = MainFeaturePrimitive.Action
}

// MARK: - SwiftUI

@ViewAction(for: MainFeature.self)
public struct MainView: View {
	@Bindable public var store: StoreOf<MainFeature>
	
	public init(store: StoreOf<MainFeature>) {
		self.store = store
	}
	
	public var body: some View {
		MainViewPrimitive(store: Primitive.Store(
			state: $store.view,
			action: { send($0) }
		)) {
			PokemonListView(store: store.scope(state: \.pokemonList, action: \.pokemonList))
		}
		.alert($store.scope(
			state: \.alert,
			action: \.alert
		))
	}
}

// MARK: - SwiftUI Previews

#Preview {
	MainView(store: Store(
		initialState: MainFeature.State(user: Shared(value: .mock))
	) {
		MainFeature()
	})
}
