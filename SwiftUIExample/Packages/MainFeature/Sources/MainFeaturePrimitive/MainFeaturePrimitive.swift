import ApiClientPrimitive
import DesignSystem
import PokemonListFeaturePrimitive
import StorePrimitive
import SwiftUI

public enum MainFeaturePrimitive: Primitive.Reducer {
	public struct State: Equatable, Sendable {
		public var user: ApiClient.User
		public var selectedTab: Tab
		
		public init(user: ApiClient.User, selectedTab: Tab = .pokemonList) {
			self.user = user
			self.selectedTab = selectedTab
		}
	}
	
	/// The tab selection binds directly to `State`, so only non-binding events are actions.
	public enum Action: Equatable, Sendable {
		case logoutButtonTapped
	}
	
	public enum Tab: Hashable, Sendable {
		case pokemonList
		case account
	}
}

// MARK: - SwiftUI

public struct MainViewPrimitive<PokemonList: View>: View, Primitive.ViewAction {
	@Primitive.Bindable public var store: Primitive.StoreOf<MainFeaturePrimitive>
	public let pokemonList: PokemonList
	
	public init(store: Primitive.StoreOf<MainFeaturePrimitive>, @ViewBuilder pokemonList: () -> PokemonList) {
		self.store = store
		self.pokemonList = pokemonList()
	}
	
	public var body: some View {
		TabView(selection: $store.selectedTab) {
			pokemonList
				.tabItem { Label("Pokédex", systemImage: "circle.grid.2x2.fill") }
				.tag(MainFeaturePrimitive.Tab.pokemonList)
			
			NavigationStack {
				ScrollView {
					VStack(spacing: Theme.Spacing.xl) {
						Card {
							VStack(spacing: Theme.Spacing.m) {
								Avatar(name: store.user.name, size: 88)
								Text(store.user.name)
									.font(.rounded(.title2, weight: .bold))
								Text(store.user.email)
									.foregroundStyle(.secondary)
							}
						}
						Button("Log out", role: .destructive) { send(.logoutButtonTapped) }
							.buttonStyle(.secondary)
							.tint(.red)
					}
					.padding(Theme.Spacing.xl)
					.frame(maxWidth: 480)
					.frame(maxWidth: .infinity)
				}
				.navigationTitle("Account")
			}
			.tabItem { Label("Account", systemImage: "person.crop.circle.fill") }
			.tag(MainFeaturePrimitive.Tab.account)
		}
	}
}

// MARK: - SwiftUI Previews

#Preview {
	MainViewPrimitive(store: .preview(.init(user: .mock))) {
		NavigationStack {
			PokemonListViewPrimitive(store: .constant(.init(user: .mock, pokemon: ApiClient.Pokemon.mocks)))
		}
	}
}
