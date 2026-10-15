import DesignSystem
import StorePrimitive
import SwiftUI

public enum LandingPagesFeaturePrimitive: Primitive.Reducer {
	public struct State: Equatable, Sendable {
		public var pages: [Page]
		public var selection: Page.ID
		
		public init(pages: [Page] = Page.all, selection: Page.ID? = nil) {
			self.pages = pages
			self.selection = selection ?? pages.first?.id ?? 0
		}
		
		public var isLastPage: Bool {
			selection == pages.last?.id
		}
	}
	
	/// The page selection binds directly to `State`, so only non-binding events are actions.
	public enum Action: Equatable, Sendable {
		case nextButtonTapped
		case loginButtonTapped
	}
	
	public struct Page: Equatable, Identifiable, Sendable {
		public let id: Int
		public var title: String
		public var subtitle: String
		public var systemImage: String
		
		public init(id: Int, title: String, subtitle: String, systemImage: String) {
			self.id = id
			self.title = title
			self.subtitle = subtitle
			self.systemImage = systemImage
		}
		
		public static let all: [Self] = [
			Self(id: 0, title: "Welcome", subtitle: "Browse the original 151 Pokémon.", systemImage: "circle.grid.2x2"),
			Self(id: 1, title: "Pick favorites", subtitle: "Star the ones you love.", systemImage: "star"),
			Self(id: 2, title: "Gotta catch 'em all", subtitle: "Log in to start your Pokédex.", systemImage: "checkmark.seal"),
		]
	}
}

// MARK: - SwiftUI

public struct LandingPagesViewPrimitive: View, Primitive.ViewAction {
	@Primitive.Bindable public var store: Primitive.StoreOf<LandingPagesFeaturePrimitive>
	
	public init(store: Primitive.StoreOf<LandingPagesFeaturePrimitive>) {
		self.store = store
	}
	
	public var body: some View {
		VStack(spacing: Theme.Spacing.xl) {
			pages
			PageIndicator(count: store.pages.count, selection: $store.selection)
			VStack(spacing: Theme.Spacing.m) {
				Button {
					send(.loginButtonTapped)
				} label: {
					Text("Log in")
				}
				.buttonStyle(.primary)
				if !store.isLastPage {
					Button("Next") { send(.nextButtonTapped, animation: .snappy) }
						.buttonStyle(.secondary)
				}
			}
			.frame(maxWidth: 480)
		}
		.padding(.horizontal, Theme.Spacing.xl)
		.padding(.bottom, Theme.Spacing.xl)
	}
	
	@ViewBuilder
	private var pages: some View {
		#if os(iOS) || os(visionOS)
		TabView(selection: $store.selection) {
			ForEach(store.pages) { page in
				PageView(page: page).tag(page.id)
			}
		}
		.tabViewStyle(.page(indexDisplayMode: .never))
		#else
		ZStack {
			if let page = store.pages.first(where: { $0.id == store.selection }) {
				PageView(page: page)
					.id(page.id)
					.transition(.push(from: .trailing))
			}
		}
		.frame(maxHeight: .infinity)
		#endif
	}
}

private struct PageView: View {
	let page: LandingPagesFeaturePrimitive.Page
	
	var body: some View {
		VStack(spacing: Theme.Spacing.xl) {
			Spacer()
			ZStack {
				Circle()
					.fill(RadialGradient(colors: [Theme.accent.opacity(0.25), .clear], center: .center, startRadius: 0, endRadius: 130))
					.frame(width: 260, height: 260)
				if page.id == 0 {
					Pokeball(size: 120)
				} else {
					Image(systemName: page.systemImage)
						.font(.system(size: 56, weight: .semibold))
						.foregroundStyle(.white)
						.frame(width: 120, height: 120)
						.background(
							LinearGradient(colors: [Theme.accent, Theme.accentDeep], startPoint: .topLeading, endPoint: .bottomTrailing),
							in: .circle
						)
						.shadow(color: Theme.accent.opacity(0.35), radius: 16, y: 8)
				}
			}
			VStack(spacing: Theme.Spacing.s) {
				Text(page.title)
					.font(.rounded(.largeTitle, weight: .bold))
				Text(page.subtitle)
					.font(.rounded(.title3))
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
			}
			Spacer()
		}
		.padding(.horizontal)
	}
}

// MARK: - SwiftUI Previews

#Preview {
	LandingPagesViewPrimitive(store: .preview(.init()))
}
