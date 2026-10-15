import SwiftUI

// MARK: - InputField

/// A filled text field with a leading icon.
public struct InputField: View {
	let title: String
	let systemImage: String
	@Binding var text: String
	let isSecure: Bool

	public init(_ title: String, systemImage: String, text: Binding<String>, isSecure: Bool = false) {
		self.title = title
		self.systemImage = systemImage
		self._text = text
		self.isSecure = isSecure
	}

	public var body: some View {
		HStack(spacing: Theme.Spacing.m) {
			Image(systemName: systemImage)
				.foregroundStyle(.secondary)
				.frame(width: 20)
			Group {
				if isSecure {
					SecureField(title, text: $text)
				} else {
					TextField(title, text: $text)
				}
			}
			.textFieldStyle(.plain)
		}
		.padding(.horizontal, Theme.Spacing.l)
		.frame(minHeight: 52)
		.background(.background.secondary, in: .rect(cornerRadius: Theme.Radius.medium))
		.overlay {
			RoundedRectangle(cornerRadius: Theme.Radius.medium)
				.strokeBorder(.quaternary)
		}
	}
}

// MARK: - Card

/// A rounded, softly filled container.
public struct Card<Content: View>: View {
	let content: Content

	public init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}

	public var body: some View {
		content
			.padding(Theme.Spacing.xl)
			.frame(maxWidth: .infinity)
			.background(.background.secondary, in: .rect(cornerRadius: Theme.Radius.large))
	}
}

// MARK: - Avatar

/// Initials on an accent gradient.
public struct Avatar: View {
	let name: String
	let size: CGFloat

	public init(name: String, size: CGFloat = 44) {
		self.name = name
		self.size = size
	}

	public var body: some View {
		Text(initials)
			.font(.system(size: size * 0.4, weight: .bold, design: .rounded))
			.foregroundStyle(.white)
			.frame(width: size, height: size)
			.background(
				LinearGradient(colors: [Theme.accent, Theme.accentDeep], startPoint: .topLeading, endPoint: .bottomTrailing),
				in: .circle
			)
	}

	private var initials: String {
		let letters = name.split(separator: " ").prefix(2).compactMap(\.first)
		return letters.isEmpty ? "?" : String(letters).uppercased()
	}
}

// MARK: - NumberBadge

/// A Pokédex number, e.g. `#025`.
public struct NumberBadge: View {
	let number: Int

	public init(_ number: Int) {
		self.number = number
	}

	public var body: some View {
		Text("#\(String(format: "%03d", number))")
			.font(.rounded(.caption, weight: .semibold).monospacedDigit())
			.foregroundStyle(.secondary)
			.padding(.horizontal, Theme.Spacing.s)
			.padding(.vertical, Theme.Spacing.xs)
			.background(.background.opacity(0.7), in: .capsule)
	}
}

// MARK: - PageIndicator

public struct PageIndicator: View {
	let count: Int
	@Binding var selection: Int

	public init(count: Int, selection: Binding<Int>) {
		self.count = count
		self._selection = selection
	}

	public var body: some View {
		HStack(spacing: Theme.Spacing.s) {
			ForEach(0..<count, id: \.self) { index in
				Capsule()
					.fill(index == selection ? AnyShapeStyle(Theme.accent) : AnyShapeStyle(.quaternary))
					.frame(width: index == selection ? 24 : 8, height: 8)
					.onTapGesture { selection = index }
			}
		}
		.animation(.snappy, value: selection)
	}
}

// MARK: - Pokeball

/// The brand mark.
public struct Pokeball: View {
	let size: CGFloat

	public init(size: CGFloat = 64) {
		self.size = size
	}

	public var body: some View {
		let line = size * 0.07
		ZStack {
			Circle().fill(.white)
			Circle().trim(from: 0.5, to: 1).fill(Theme.accent)
			Rectangle().fill(.black).frame(height: line)
			Circle().fill(.white).frame(width: size * 0.32, height: size * 0.32)
			Circle().strokeBorder(.black, lineWidth: line).frame(width: size * 0.32, height: size * 0.32)
			Circle().strokeBorder(.black, lineWidth: line)
		}
		.frame(width: size, height: size)
		.shadow(color: .black.opacity(0.15), radius: size * 0.1, y: size * 0.05)
	}
}

// MARK: - PokemonSprite

/// A pixel-art sprite on a soft circle of its tint.
public struct PokemonSprite: View {
	let url: URL
	let tint: Color
	let size: CGFloat

	public init(url: URL, tint: Color, size: CGFloat) {
		self.url = url
		self.tint = tint
		self.size = size
	}

	public var body: some View {
		ZStack {
			Circle()
				.fill(RadialGradient(colors: [tint.opacity(0.45), tint.opacity(0.05)], center: .center, startRadius: 0, endRadius: size * 0.55))
			AsyncImage(url: url) { image in
				image
					.resizable()
					.interpolation(.none)
					.scaledToFit()
			} placeholder: {
				ProgressView()
			}
			.padding(size * 0.08)
		}
		.frame(width: size, height: size)
	}
}

// MARK: - PokemonCard

/// A grid cell: sprite, name and number on the Pokémon's tint.
public struct PokemonCard: View {
	let name: String
	let number: Int
	let imageURL: URL

	public init(name: String, number: Int, imageURL: URL) {
		self.name = name
		self.number = number
		self.imageURL = imageURL
	}

	public var body: some View {
		let tint = Theme.tint(for: number)
		VStack(spacing: Theme.Spacing.s) {
			PokemonSprite(url: imageURL, tint: tint, size: 104)
			Text(name.capitalized)
				.font(.rounded(.headline))
				.lineLimit(1)
			NumberBadge(number)
		}
		.padding(.vertical, Theme.Spacing.l)
		.frame(maxWidth: .infinity)
		.background {
			RoundedRectangle(cornerRadius: Theme.Radius.large)
				.fill(.background.secondary)
				.overlay {
					RoundedRectangle(cornerRadius: Theme.Radius.large)
						.fill(LinearGradient(colors: [tint.opacity(0.22), tint.opacity(0.04)], startPoint: .top, endPoint: .bottom))
				}
		}
		.contentShape(.rect(cornerRadius: Theme.Radius.large))
	}
}

// MARK: - FavoriteButton

/// A star that bounces when toggled.
public struct FavoriteButton: View {
	let isFavorite: Bool
	let action: () -> Void

	public init(isFavorite: Bool, action: @escaping () -> Void) {
		self.isFavorite = isFavorite
		self.action = action
	}

	public var body: some View {
		Button(action: action) {
			Image(systemName: isFavorite ? "star.fill" : "star")
				.font(.system(size: 16, weight: .semibold))
				.foregroundStyle(isFavorite ? AnyShapeStyle(Theme.star) : AnyShapeStyle(.secondary))
				.symbolEffect(.bounce, value: isFavorite)
				.frame(width: 36, height: 36)
				.background(.background.opacity(0.8), in: .circle)
		}
		.buttonStyle(.plain)
		.accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
	}
}
