import ApiClient
import AppState
import ComposableArchitecture
@_exported import PokemonDetailsFeaturePrimitive
import StorePrimitive
import SwiftUI

@Reducer
public struct PokemonDetailsFeature {
	
	@ObservableState
	public struct State: Equatable {
		@Shared(.favoritePokemonIDs) public var favoritePokemonIDs
		public var pokemon: ApiClient.Pokemon
		
		public init(pokemon: ApiClient.Pokemon) {
			self.pokemon = pokemon
		}
		
		public var view: Self.View {
			.init(pokemon: pokemon, isFavorite: favoritePokemonIDs.contains(pokemon.id))
		}
	}
	
	public enum Action: ViewAction {
		case view(Self.View)
	}
	
	public init() {}
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				
			case let .view(action):
				switch action {
					
				case .favoriteButtonTapped:
					state.$favoritePokemonIDs.withLock { [id = state.pokemon.id] in $0.formSymmetricDifference([id]) }
					return .none
				}
			}
		}
	}
}

extension PokemonDetailsFeature.State {
	public typealias View = PokemonDetailsFeaturePrimitive.State
}

extension PokemonDetailsFeature.Action {
	public typealias View = PokemonDetailsFeaturePrimitive.Action
}

// MARK: - SwiftUI

@ViewAction(for: PokemonDetailsFeature.self)
public struct PokemonDetailsView: View {
	@Bindable public var store: StoreOf<PokemonDetailsFeature>
	
	public init(store: StoreOf<PokemonDetailsFeature>) {
		self.store = store
	}
	
	public var body: some View {
		PokemonDetailsViewPrimitive(store: Primitive.Store(
			state: { store.view },
			action: { send($0) }
		))
	}
}

// MARK: - SwiftUI Previews

#Preview {
	NavigationStack {
		PokemonDetailsView(store: Store(
			initialState: PokemonDetailsFeature.State(pokemon: ApiClient.Pokemon.mocks[3])
		) {
			PokemonDetailsFeature()
		})
	}
}
