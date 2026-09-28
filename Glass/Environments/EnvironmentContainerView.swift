import SwiftUI

/// Reusable host for whichever environment is active. Each future
/// environment (VOID, FLUID, ORBIT, PLAYGROUND, LIGHT) becomes its own
/// `View` and gets a case here — the container, transition, and layout
/// stay untouched.
struct EnvironmentContainerView: View {
    let mode: EnvironmentMode
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            content
        }
        .id(mode)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(transition)
    }

    @ViewBuilder
    private var content: some View {
        switch mode {
        case .void: VoidEnvironmentView(reduceMotion: reduceMotion)
        case .fluid: PlaceholderEnvironmentView(mode: .fluid)
        case .orbit: PlaceholderEnvironmentView(mode: .orbit)
        case .playground: PlaceholderEnvironmentView(mode: .playground)
        case .light: PlaceholderEnvironmentView(mode: .light)
        }
    }

    private var transition: AnyTransition {
        guard !reduceMotion else { return .opacity }
        // A small, calm scale rather than a pop — the mode switch should
        // read as a slow physical settle, not a flashy effect.
        return .asymmetric(
            insertion: .scale(scale: 0.97).combined(with: .opacity),
            removal: .scale(scale: 1.02).combined(with: .opacity)
        )
    }
}
