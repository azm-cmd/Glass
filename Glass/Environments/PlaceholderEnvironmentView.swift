import SwiftUI

/// Stand-in scene shown for every mode until each environment gets its own
/// implementation. Intentionally plain: a glyph and label centered in the
/// shared stage, no color or glow of their own.
struct PlaceholderEnvironmentView: View {
    let mode: EnvironmentMode

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: mode.symbolName)
                .font(.system(size: 50, weight: .thin))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white.opacity(0.85))

            VStack(spacing: 6) {
                Text(mode.title)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .tracking(6)
                    .foregroundStyle(.white.opacity(0.85))

                Text(mode.subtitle)
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.35))
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
