import SwiftUI

// MARK: - Preview

/// Helpers for `#Preview`s. `Preview.tab(.pokedex) { … }` shows a screen inside the app's tab bar,
/// without needing the feature that owns the real `TabView`.
public enum Preview {
	public enum Tab: CaseIterable, Hashable {
		case pokedex
		case account
		
		var title: String {
			switch self {
			case .pokedex: "Pokédex"
			case .account: "Account"
			}
		}
		
		var systemImage: String {
			switch self {
			case .pokedex: "circle.grid.2x2.fill"
			case .account: "person.crop.circle.fill"
			}
		}
	}
	
	@MainActor
	public static func tab<Content: View>(_ tab: Tab, @ViewBuilder content: () -> Content) -> some View {
		TabPreview(selection: tab, content: content())
	}
}

private struct TabPreview<Content: View>: View {
	@State var selection: Preview.Tab
	let content: Content
	
	var body: some View {
		TabView(selection: $selection) {
			ForEach(Preview.Tab.allCases, id: \.self) { tab in
				Group {
					if tab == selection {
						content
					} else {
						Color.clear
					}
				}
				.tabItem { Label(tab.title, systemImage: tab.systemImage) }
				.tag(tab)
			}
		}
		.tint(Theme.accent)
		.font(.rounded(.body))
	}
}
