import SwiftUI

/// Full-screen dark backdrop. Deliberately almost featureless — a plain
/// black field with one faint neutral glow from above — so the Liquid
/// Glass controls and whatever objects an environment places on top are
/// the only things doing visual work.
struct BackgroundView: View {
    var body: some View {
        ZStack {
            Color.black

            RadialGradient(
                colors: [Color.white.opacity(0.05), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 640
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}
