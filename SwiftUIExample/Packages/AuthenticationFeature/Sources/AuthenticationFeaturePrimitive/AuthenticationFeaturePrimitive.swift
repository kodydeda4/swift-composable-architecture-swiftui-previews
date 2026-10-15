import DesignSystem
import LandingPagesFeaturePrimitive
import SwiftUI

// MARK: - SwiftUI

public struct AuthenticationViewPrimitive<Stack: View>: View {
	public let stack: Stack
	
	public init(@ViewBuilder stack: () -> Stack) {
		self.stack = stack()
	}
	
	public var body: some View {
		stack
			.tint(Theme.accent)
	}
}

// MARK: - SwiftUI Previews

#Preview {
	AuthenticationViewPrimitive {
		NavigationStack {
			LandingPagesViewPrimitive(store: .preview(.init()))
		}
	}
}
