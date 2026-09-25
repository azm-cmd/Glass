import SwiftUI

/// Stand-in scene shown for every mode until each environment gets its own
/// implementation. Intentionally simple: a glowing glyph and label centered
/// in the shared stage.
struct PlaceholderEnvironmentView: View {
    let mode: EnvironmentMode

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: mode.symbolName)
                .font(.system(size: 58, weight: .thin))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(mode.accentColor)
                .shadow(color: mode.accentColor.opacity(0.55), radius: 36)

            VStack(spacing: 6) {
                Text(mode.title)
                    .font(.system(.title2, design: .rounded, weight: .semibold))
                    .tracking(6)
                    .foregroundStyle(.white.opacity(0.9))

                Text(mode.subtitle)
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PlaceholderEnvironmentView(mode: .orbit)
    }
}
