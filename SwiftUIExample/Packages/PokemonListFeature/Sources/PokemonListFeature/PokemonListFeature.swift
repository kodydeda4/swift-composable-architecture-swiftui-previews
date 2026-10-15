import ApiClient
import AppState
import ComposableArchitecture
import PokemonDetailsFeature
import SettingsFeature
import StorePrimitive
import SwiftUI
@_exported import PokemonListFeaturePrimitive

@Reducer
public struct PokemonListFeature {
	
	@Reducer
	public enum Destination {
		case settings(SettingsFeature)
	}
	
	@Reducer
	public enum Path {
		case details(PokemonDetailsFeature)
	}
	
	@ObservableState
	public struct State: Equatable {
		@Presents public var destination: Destination.State? = nil
		public var path = StackState<Path.State>()
		@Shared public var user: ApiClient.User
		@Shared(.favoritePokemonIDs) public var favoritePokemonIDs
		public var pokemon: [ApiClient.Pokemon] = []
		public var isLoading = false
		
		public init(user: Shared<ApiClient.User>) {
			self._user = user
		}
		
		public var view: Self.View {
			.init(user: user, pokemon: pokemon, favoriteIDs: favoritePokemonIDs, isLoading: isLoading)
		}
	}
	
	public enum Action: ViewAction {
		case view(Self.View)
		case destination(PresentationAction<Destination.Action>)
		case path(StackActionOf<Path>)
		case pokemonResponse(Result<[ApiClient.Pokemon], any Error>)
	}
	
	@Dependency(\.apiClient) var apiClient
	
	public init() {}
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				
			case let .destination(.presented(.settings(.delegate(.didSave(name))))):
				state.$user.withLock { $0.name = name }
				return .none
				
			case .destination, .path:
				return .none
				
			case let .pokemonResponse(.success(pokemon)):
				state.isLoading = false
				state.pokemon = pokemon
				return .none
				
			case .pokemonResponse(.failure):
				state.isLoading = false
				return .none
				
			case let .view(action):
				switch action {
					
				case .task:
					guard state.pokemon.isEmpty else { return .none }
					state.isLoading = true
					return .run { [apiClient] send in
						await send(.pokemonResponse(.success(try await apiClient.fetchPokemon(.init()).pokemon)))
					} catch: { error, send in
						await send(.pokemonResponse(.failure(error)))
					}
					
				case let .pokemonTapped(pokemon):
					state.path.append(.details(.init(pokemon: pokemon)))
					return .none
					
				case let .favoriteTapped(id):
					state.$favoritePokemonIDs.withLock { $0.formSymmetricDifference([id]) }
					return .none
					
				case .settingsButtonTapped:
					state.destination = .settings(.init(name: state.user.name))
					return .none
				}
			}
		}
		.ifLet(\.$destination, action: \.destination)
		.forEach(\.path, action: \.path)
	}
}

extension PokemonListFeature.Destination.State: Equatable {}
extension PokemonListFeature.Path.State: Equatable {}


extension PokemonListFeature.State {
	public typealias View = PokemonListFeaturePrimitive.State
}

extension PokemonListFeature.Action {
	public typealias View = PokemonListFeaturePrimitive.Action
}

// MARK: - SwiftUI

@ViewAction(for: PokemonListFeature.self)
public struct PokemonListView: View {
	@Bindable public var store: StoreOf<PokemonListFeature>
	
	public init(store: StoreOf<PokemonListFeature>) {
		self.store = store
	}
	
	public var body: some View {
		NavigationStack(path: $store.scope(
			state: \.path,
			action: \.path
		)) {
			PokemonListViewPrimitive(store: StorePrimitive(
				state: { store.view },
				action: { send($0) }
			))
			.sheet(item: $store.scope(
				state: \.destination?.settings,
				action: \.destination.settings
			)) { store in
				SettingsView(store: store)
			}
		} destination: { store in
			switch store.case {
				
			case let .details(store):
				PokemonDetailsView(store: store)
			}
		}
	}
}

// MARK: - SwiftUI Previews

#Preview {
	PokemonListView(store: Store(
		initialState: PokemonListFeature.State(user: Shared(value: .mock))
	) {
		PokemonListFeature()
	})
}
