import SwiftUI

/// Full-screen dark, deep-space backdrop with very subtle ambient light
/// tied to the active environment's accent color.
struct BackgroundView: View {
    let accent: Color

    var body: some View {
        ZStack {
            Color.black

            RadialGradient(
                colors: [accent.opacity(0.22), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 520
            )
            .blur(radius: 60)

            RadialGradient(
                colors: [Color.white.opacity(0.05), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 460
            )
            .blur(radius: 80)

            LinearGradient(
                colors: [Color.black.opacity(0), Color.black.opacity(0.4)],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.6), value: accent)
    }
}

#Preview {
    BackgroundView(accent: EnvironmentMode.light.accentColor)
}
