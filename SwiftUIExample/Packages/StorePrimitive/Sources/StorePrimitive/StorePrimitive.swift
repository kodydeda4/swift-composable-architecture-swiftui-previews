import Observation
import SwiftUI

// MARK: - A store-shaped primitive. NO THIRD PARTY.
// Vanilla views read and bind to `state`, and call `send`. They don't know (or care) what's behind it:
// a preview box in previews, a TCA `Store` (via an `@ViewAction` view) in the app.
// It doesn't do anything itself. Whatever the closures read must be observable
// (`@Observable`, TCA's `Store`) for views to update.

/// Vanilla counterparts of TCA's types: `Primitive.Reducer`, `Primitive.StoreOf`,
/// `Primitive.Bindable` and `Primitive.ViewAction` (a view's `send(...)`, like `@ViewAction`).
public enum Primitive {
	/// A namespace for a vanilla feature's `State` and `Action`, so views can say
	/// `Primitive.StoreOf<LoginFeaturePrimitive>` the way TCA says `StoreOf<LoginFeature>`.
	public protocol Reducer {
		associatedtype State
		associatedtype Action
	}

	public typealias StoreOf<Feature: Reducer> = StorePrimitive<Feature.State, Feature.Action>
}

/// Read with `store.email` and send with `send(...)` (`Primitive.ViewAction`).
/// For bindings, declare it as `@Primitive.Bindable var store` and use `$store.email`.
@MainActor
@dynamicMemberLookup
public struct StorePrimitive<State, Action> {
	@Binding public var state: State
	private let sendAction: (Action) -> Void

	public init(state: Binding<State>, action: @escaping (Action) -> Void) {
		self._state = state
		self.sendAction = action
	}

	/// Read-only state. Binding writes are ignored.
	public init(state: @escaping () -> State, action: @escaping (Action) -> Void) {
		self.init(state: Binding(get: state, set: { _ in }), action: action)
	}

	public subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
		state[keyPath: keyPath]
	}

	public func send(_ action: Action) {
		sendAction(action)
	}
}

// MARK: - Bindings. The vanilla counterpart of TCA's `@Bindable var store`.

extension Primitive {
	/// Wrap a view's store to bind to its state: `TextField("Email", text: $store.email)`.
	@MainActor
	@propertyWrapper
	public struct Bindable<State, Action> {
		public var wrappedValue: StorePrimitive<State, Action>

		public init(wrappedValue: StorePrimitive<State, Action>) {
			self.wrappedValue = wrappedValue
		}

		/// `$store.email` is a `Binding<String>`, via `Binding`'s own dynamic member lookup.
		public var projectedValue: Binding<State> {
			wrappedValue.$state
		}
	}
}

// MARK: - Views that own a store. The vanilla counterpart of TCA's `@ViewAction`.

extension Primitive {
	/// Conform a vanilla view to call `send(.loginButtonTapped)` instead of `store.send(...)`.
	/// `State` and `Action` are inferred from the `store` property.
	@MainActor
	public protocol ViewAction {
		associatedtype State
		associatedtype Action

		var store: StorePrimitive<State, Action> { get }
	}
}

extension Primitive.ViewAction {
	public func send(_ action: Action) {
		store.send(action)
	}

	public func send(_ action: Action, animation: Animation?) {
		withAnimation(animation) {
			store.send(action)
		}
	}
}

// MARK: - Previews

extension StorePrimitive {
	/// Fixed state. Binding writes and actions are ignored.
	public static func constant(_ state: State) -> Self {
		Self(state: .constant(state), action: { _ in })
	}

	/// Mutable, observable state. Binding writes apply directly; `reduce` defaults to ignoring actions.
	public static func preview(
		_ state: State,
		reduce: @escaping (inout State, Action) -> Void = { _, _ in }
	) -> Self {
		let box = PreviewBox(state, reduce: reduce)
		return Self(state: Binding(get: { box.state }, set: { box.state = $0 }), action: { box.send($0) })
	}
}

@MainActor
@Observable
private final class PreviewBox<State, Action> {
	var state: State
	@ObservationIgnored let reduce: (inout State, Action) -> Void

	init(_ state: State, reduce: @escaping (inout State, Action) -> Void) {
		self.state = state
		self.reduce = reduce
	}

	func send(_ action: Action) {
		reduce(&state, action)
	}
}
