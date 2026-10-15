import ApiClientPrimitive
import DesignSystem
import StorePrimitive
import SwiftUI

public enum PokemonDetailsFeaturePrimitive: Primitive.Reducer {
	public struct State: Equatable, Sendable {
		public var pokemon: ApiClient.Pokemon
		public var isFavorite: Bool
		
		public init(pokemon: ApiClient.Pokemon, isFavorite: Bool = false) {
			self.pokemon = pokemon
			self.isFavorite = isFavorite
		}
	}
	
	public enum Action: Equatable, Sendable {
		case favoriteButtonTapped
	}
}

// MARK: - SwiftUI

public struct PokemonDetailsViewPrimitive: View, Primitive.ViewAction {
	public let store: Primitive.StoreOf<PokemonDetailsFeaturePrimitive>
	
	public init(store: Primitive.StoreOf<PokemonDetailsFeaturePrimitive>) {
		self.store = store
	}
	
	public var body: some View {
		let tint = Theme.tint(for: store.pokemon.id)
		ScrollView {
			VStack(spacing: Theme.Spacing.xl) {
				PokemonSprite(url: store.pokemon.spriteURL, tint: tint, size: 240)
				VStack(spacing: Theme.Spacing.s) {
					NumberBadge(store.pokemon.id)
					Text(store.pokemon.name.capitalized)
						.font(.system(size: 40, weight: .bold, design: .rounded))
				}
				Button {
					send(.favoriteButtonTapped)
				} label: {
					Label(
						store.isFavorite ? "Favorited" : "Add to favorites",
						systemImage: store.isFavorite ? "star.fill" : "star"
					)
					.symbolEffect(.bounce, value: store.isFavorite)
				}
				.buttonStyle(.secondary)
			}
			.padding(Theme.Spacing.xl)
			.frame(maxWidth: 480)
			.frame(maxWidth: .infinity)
		}
		.background {
			LinearGradient(colors: [tint.opacity(0.35), tint.opacity(0)], startPoint: .top, endPoint: .center)
				.ignoresSafeArea()
		}
		.navigationTitle(store.pokemon.name.capitalized)
		#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
		#endif
	}
}

// MARK: - SwiftUI Previews

#Preview {
	NavigationStack {
		PokemonDetailsViewPrimitive(store: .constant(.init(pokemon: ApiClient.Pokemon.mocks[3])))
	}
}
