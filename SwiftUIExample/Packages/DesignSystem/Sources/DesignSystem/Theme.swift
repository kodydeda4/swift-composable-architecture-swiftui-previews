import SwiftUI

// MARK: - Tokens

public enum Theme {
	/// Pokédex red.
	public static let accent = Color(red: 0.89, green: 0.21, blue: 0.05)
	public static let accentDeep = Color(red: 0.66, green: 0.10, blue: 0.04)
	public static let star = Color(red: 1.00, green: 0.78, blue: 0.15)

	/// A stable tint per Pokémon, so each one gets its own color.
	public static func tint(for id: Int) -> Color {
		Color(hue: Double((id * 37) % 360) / 360, saturation: 0.55, brightness: 0.90)
	}

	public enum Spacing {
		public static let xs: CGFloat = 4
		public static let s: CGFloat = 8
		public static let m: CGFloat = 12
		public static let l: CGFloat = 16
		public static let xl: CGFloat = 24
		public static let xxl: CGFloat = 32
	}

	public enum Radius {
		public static let small: CGFloat = 10
		public static let medium: CGFloat = 16
		public static let large: CGFloat = 24
	}
}

// MARK: - Type

extension Font {
	/// The app's type: SF Rounded at a text style's default size. `.font(.rounded(.headline))`.
	public static func rounded(_ style: Font.TextStyle, weight: Font.Weight? = nil) -> Font {
		.system(size: style.pointSize, weight: weight ?? style.defaultWeight, design: .rounded)
	}
}

extension Font.TextStyle {
	fileprivate var pointSize: CGFloat {
		switch self {
		case .largeTitle: 34
		case .title: 28
		case .title2: 22
		case .title3: 20
		case .headline, .body: 17
		case .callout: 16
		case .subheadline: 15
		case .footnote: 13
		case .caption: 12
		case .caption2: 11
		@unknown default: 17
		}
	}
	
	fileprivate var defaultWeight: Font.Weight {
		self == .headline ? .semibold : .regular
	}
}
