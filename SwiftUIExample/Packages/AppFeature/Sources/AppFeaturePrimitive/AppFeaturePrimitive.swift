import ApiClientPrimitive
import AuthenticationFeaturePrimitive
import DesignSystem
import LandingPagesFeaturePrimitive
import MainFeaturePrimitive
import StorePrimitive
import SwiftUI
import PokemonListFeaturePrimitive

// MARK: - SwiftUI

public struct AppViewPrimitive<Authentication: View, Main: View>: View {
	public enum Destination {
		case authentication(Authentication)
		case main(Main)
	}
	
	public let destination: Destination?
	
	public init(destination: Destination?) {
		self.destination = destination
	}
	
	public var body: some View {
		ZStack {
			switch destination {
				
			case let .authentication(view):
				view.transition(.move(edge: .leading))
				
			case let .main(view):
				view.transition(.move(edge: .trailing))
				
			case .none:
				ProgressView()
			}
		}
		.animation(.default, value: isLoggedIn)
		.tint(Theme.accent)
		.font(.rounded(.body))
	}
	
	private var isLoggedIn: Bool {
		if case .main = destination { true } else { false }
	}
}

// MARK: - SwiftUI Previews

#Preview {
	AppViewPrimitive<AuthenticationViewPrimitive<NavigationStack<NavigationPath, LandingPagesViewPrimitive>>, EmptyView>(
		destination: .authentication(AuthenticationViewPrimitive {
			NavigationStack {
				LandingPagesViewPrimitive(store: .preview(.init()))
			}
		})
	)
}
