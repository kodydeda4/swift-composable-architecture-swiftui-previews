import ApiClientPrimitive
import DesignSystem
import StorePrimitive
import SwiftUI

public enum PokemonListFeaturePrimitive: Primitive.Reducer {
	public struct State: Equatable, Sendable {
		public var user: ApiClient.User
		public var pokemon: [ApiClient.Pokemon]
		public var favoriteIDs: Set<ApiClient.Pokemon.ID>
		public var isLoading: Bool
		
		public init(
			user: ApiClient.User,
			pokemon: [ApiClient.Pokemon] = [],
			favoriteIDs: Set<ApiClient.Pokemon.ID> = [],
			isLoading: Bool = false
		) {
			self.user = user
			self.pokemon = pokemon
			self.favoriteIDs = favoriteIDs
			self.isLoading = isLoading
		}
	}
	
	public enum Action: Equatable, Sendable {
		case task
		case settingsButtonTapped
		case pokemonTapped(ApiClient.Pokemon)
		case favoriteTapped(id: ApiClient.Pokemon.ID)
	}
}

// MARK: - SwiftUI

public struct PokemonListViewPrimitive: View, Primitive.ViewAction {
	public let store: Primitive.StoreOf<PokemonListFeaturePrimitive>
	
	public init(store: Primitive.StoreOf<PokemonListFeaturePrimitive>) {
		self.store = store
	}
	
	public var body: some View {
		ScrollView {
			LazyVGrid(columns: [GridItem(.adaptive(minimum: 156), spacing: Theme.Spacing.l)], spacing: Theme.Spacing.l) {
				ForEach(store.pokemon) { pokemon in
					Button {
						send(.pokemonTapped(pokemon))
					} label: {
						PokemonCard(name: pokemon.name, number: pokemon.id, imageURL: pokemon.spriteURL)
					}
					.buttonStyle(.card)
					.overlay(alignment: .topTrailing) {
						FavoriteButton(isFavorite: store.favoriteIDs.contains(pokemon.id)) {
							send(.favoriteTapped(id: pokemon.id))
						}
						.padding(Theme.Spacing.s)
					}
				}
			}
			.padding(Theme.Spacing.l)
		}
		.overlay {
			if store.isLoading && store.pokemon.isEmpty {
				ProgressView()
					.controlSize(.large)
			}
		}
		.navigationTitle("Pokédex")
		.task { send(.task) }
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button {
					send(.settingsButtonTapped)
				} label: {
					Avatar(name: store.user.name, size: 30)
				}
				.buttonStyle(.plain)
				.accessibilityLabel("Settings")
			}
		}
	}
}

// MARK: - SwiftUI Previews

#Preview {
	Preview.tab(.pokedex) {
		NavigationStack {
			PokemonListViewPrimitive(store: .constant(.init(
				user: .mock,
				pokemon: ApiClient.Pokemon.mocks,
				favoriteIDs: [4]
			)))
		}
	}
}
