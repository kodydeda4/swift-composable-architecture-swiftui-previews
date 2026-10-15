import ApiClientPrimitive
import DesignSystem
import StorePrimitive
import SwiftUI

public enum LoginFeaturePrimitive: Primitive.Reducer {
	public struct State: Equatable, Sendable {
		public var email: String
		public var password: String
		public var isLoading: Bool
		
		public init(
			email: String = "",
			password: String = "",
			isLoading: Bool = false
		) {
			self.email = email
			self.password = password
			self.isLoading = isLoading
		}
		
		public var isLoginButtonDisabled: Bool {
			email.isEmpty || password.isEmpty || isLoading
		}
	}
	
	/// Text fields bind directly to `State`, so only non-binding events are actions.
	public enum Action: Equatable, Sendable {
		case loginButtonTapped
	}
}

// MARK: - SwiftUI

public struct LoginViewPrimitive: View, Primitive.ViewAction {
	@Primitive.Bindable public var store: Primitive.StoreOf<LoginFeaturePrimitive>
	
	public init(store: Primitive.StoreOf<LoginFeaturePrimitive>) {
		self.store = store
	}
	
	public var body: some View {
		ScrollView {
			VStack(spacing: Theme.Spacing.xxl) {
				VStack(spacing: Theme.Spacing.m) {
					Pokeball(size: 72)
					Text("Welcome back")
						.font(.rounded(.largeTitle, weight: .bold))
					Text("Log in to open your Pokédex.")
						.foregroundStyle(.secondary)
				}
				.padding(.top, Theme.Spacing.xxl)
				
				VStack(spacing: Theme.Spacing.m) {
					InputField("Email", systemImage: "envelope", text: $store.email)
						.textContentType(.emailAddress)
						.autocorrectionDisabled()
						#if os(iOS)
						.textInputAutocapitalization(.never)
						#endif
					InputField("Password", systemImage: "lock", text: $store.password, isSecure: true)
						.textContentType(.password)
				}
				
				Button {
					send(.loginButtonTapped)
				} label: {
					if store.isLoading {
						ProgressView()
							.tint(.white)
					} else {
						Text("Log in")
					}
				}
				.buttonStyle(.primary)
				.disabled(store.isLoginButtonDisabled)
			}
			.padding(Theme.Spacing.xl)
			.frame(maxWidth: 480)
			.frame(maxWidth: .infinity)
		}
		.disabled(store.isLoading)
		.navigationTitle("Log in")
		#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
		#endif
	}
}

// MARK: - SwiftUI Previews

#Preview {
	NavigationStack {
		LoginViewPrimitive(store: .preview(.init()))
	}
}
