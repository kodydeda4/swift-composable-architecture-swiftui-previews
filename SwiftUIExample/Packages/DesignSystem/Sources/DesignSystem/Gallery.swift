import SwiftUI

// MARK: - SwiftUI Previews

#Preview {
	@Previewable @State var text = ""
	@Previewable @State var page = 1

	ScrollView {
		VStack(spacing: Theme.Spacing.xl) {
			Pokeball()
			Avatar(name: "Blob Jr", size: 64)
			PokemonCard(name: "pikachu", number: 25, imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png")!)
				.frame(width: 170)
			FavoriteButton(isFavorite: true) {}
			InputField("Email", systemImage: "envelope", text: $text)
			PageIndicator(count: 3, selection: $page)
			Button("Primary") {}.buttonStyle(.primary)
			Button("Secondary") {}.buttonStyle(.secondary).tint(.red)
		}
		.padding()
	}
	.font(.rounded(.body))
}
