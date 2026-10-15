import SwiftUI

// MARK: - Primary

/// Full-width, filled with the accent. The main action on a screen.
public struct PrimaryButtonStyle: ButtonStyle {
	public init() {}

	public func makeBody(configuration: Configuration) -> some View {
		PrimaryButton(configuration: configuration)
	}

	private struct PrimaryButton: View {
		let configuration: ButtonStyleConfiguration
		@Environment(\.isEnabled) private var isEnabled

		var body: some View {
			configuration.label
				.font(.rounded(.headline))
				.foregroundStyle(.white)
				.frame(maxWidth: .infinity, minHeight: 52)
				.background(
					LinearGradient(colors: [Theme.accent, Theme.accentDeep], startPoint: .top, endPoint: .bottom),
					in: .rect(cornerRadius: Theme.Radius.medium)
				)
				.shadow(color: Theme.accent.opacity(isEnabled ? 0.35 : 0), radius: 12, y: 6)
				.opacity(isEnabled ? 1 : 0.45)
				.scaleEffect(configuration.isPressed ? 0.97 : 1)
				.animation(.snappy(duration: 0.2), value: configuration.isPressed)
				.contentShape(.rect)
		}
	}
}

extension ButtonStyle where Self == PrimaryButtonStyle {
	public static var primary: Self { .init() }
}

// MARK: - Secondary

/// Full-width, softly tinted. Follows `.tint(_:)`, e.g. `.tint(.red)` for destructive actions.
public struct SecondaryButtonStyle: ButtonStyle {
	public init() {}

	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.rounded(.headline))
			.foregroundStyle(.tint)
			.frame(maxWidth: .infinity, minHeight: 52)
			.background(.tint.opacity(configuration.isPressed ? 0.2 : 0.12), in: .rect(cornerRadius: Theme.Radius.medium))
			.scaleEffect(configuration.isPressed ? 0.97 : 1)
			.animation(.snappy(duration: 0.2), value: configuration.isPressed)
			.contentShape(.rect)
	}
}

extension ButtonStyle where Self == SecondaryButtonStyle {
	public static var secondary: Self { .init() }
}

// MARK: - Card

/// For tappable cards: no chrome, just a soft press.
public struct CardButtonStyle: ButtonStyle {
	public init() {}
	
	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 0.96 : 1)
			.opacity(configuration.isPressed ? 0.85 : 1)
			.animation(.snappy(duration: 0.2), value: configuration.isPressed)
	}
}

extension ButtonStyle where Self == CardButtonStyle {
	public static var card: Self { .init() }
}
