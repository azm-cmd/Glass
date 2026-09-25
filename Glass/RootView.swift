import SwiftUI

/// The shared app shell. Every future environment (VOID, FLUID, ORBIT,
/// PLAYGROUND, LIGHT) is hosted inside `EnvironmentContainerView` and lives
/// behind the floating `ModeSelectorView`. Nothing environment-specific
/// belongs in this file.
struct RootView: View {
    @State private var selectedMode: EnvironmentMode = .void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            BackgroundView(accent: selectedMode.accentColor)

            EnvironmentContainerView(mode: selectedMode, reduceMotion: reduceMotion)

            VStack {
                Spacer()
                ModeSelectorView(selectedMode: $selectedMode, reduceMotion: reduceMotion)
                    .padding(.bottom, 12)
            }
        }
        .ignoresSafeArea(.keyboard)
        .persistentSystemOverlays(.hidden)
    }
}

#Preview {
    RootView()
}
