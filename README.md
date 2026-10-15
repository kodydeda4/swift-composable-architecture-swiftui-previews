# Pokédex: TCA with fast previews

A TCA app whose SwiftUI previews never compile TCA.

## The idea

Every feature is a package with two targets:

<img width="219" height="116" alt="Screenshot 2026-10-15 at 2 24 51 AM" src="https://github.com/user-attachments/assets/728c3939-0e5f-408e-8200-d921c36cdc78" />

## 1. `FeaturePrimitive`

Defines the state and actions, renders the view. Purely vanilla. SwiftUI Previews.

```swift
enum LoginFeaturePrimitive: Primitive.Reducer {
  struct State { ... }
  enum Action { ... }
}

struct LoginViewPrimitive: View, Primitive.ViewAction {
  @Primitive.Bindable var store: Primitive.StoreOf<LoginFeaturePrimitive>

  var body: some View { ... }
}
```

## 2. `Feature`

Binds to the view. Handles state, actions, dependencies, coordination.

```swift
@Reducer
struct LoginFeature { ... }

@ViewAction(for: LoginFeature.self)
struct LoginView: View {
  @Bindable var store: StoreOf<LoginFeature>

  var body: some View {
    LoginViewPrimitive(store: Primitive.Store(state: $store.view, action: { send($0) }))
      .sheet(...)
      .alert(...)
      .navigationDestination(...)
      .fullScreenCover(...)
  }
}
```

## Previews

Previews live in `FeaturePrimitive`, so they never build TCA, dependencies, or child features.

```swift
#Preview {
  Preview.tab(.pokedex) {
    PokemonListViewPrimitive(store: .constant(.init(user: .mock, pokemon: ApiClient.Pokemon.mocks)))
  }
}
```

The Pokémon list preview builds 3 modules. The full screen builds 31.

## Run

Open `SwiftUIExample/SwiftUIExample.xcworkspace` and run `SwiftUIExample`.
