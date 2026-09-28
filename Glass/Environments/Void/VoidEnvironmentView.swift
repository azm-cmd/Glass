import SwiftUI

/// VOID — a few translucent physical objects floating in a dark void,
/// driven by touch and a light continuous physics simulation. Composes
/// on top of the shared shell's black backdrop (`BackgroundView`), so
/// this view stays transparent rather than painting its own background.
struct VoidEnvironmentView: View {
    let reduceMotion: Bool

    @State private var simulation = VoidSimulation()

    private let space = "voidSpace"

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { context in
                // `let _ =` (rather than a bare statement) keeps these
                // Void-returning calls from being fed into the
                // @ViewBuilder's `buildExpression`, which only accepts View
                // results.
                let _ = simulation.seedIfNeeded(size: size)
                let _ = simulation.tick(now: context.date, size: size, reduceMotion: reduceMotion)

                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(spawnGesture)

                    ForEach(simulation.blobs) { blob in
                        VoidBlobView(blob: blob)
                            .position(blob.position)
                            .simultaneousGesture(dragGesture(for: blob))
                            .onLongPressGesture(
                                minimumDuration: 0.35,
                                maximumDistance: 14,
                                perform: {},
                                onPressingChanged: { pressing in
                                    simulation.setPulsing(id: blob.id, active: pressing)
                                }
                            )
                    }
                }
                .coordinateSpace(name: space)
            }
        }
        .ignoresSafeArea()
    }

    private func dragGesture(for blob: VoidBlob) -> some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .named(space))
            .onChanged { value in
                simulation.beginDrag(id: blob.id)
                simulation.updateDrag(id: blob.id, to: value.location)
            }
            .onEnded { value in
                simulation.endDrag(
                    id: blob.id,
                    location: value.location,
                    predictedEndLocation: value.predictedEndLocation
                )
            }
    }

    /// A tap on empty space spawns a blob. Built on `DragGesture` with a
    /// zero minimum distance (rather than `SpatialTapGesture`) so a tap
    /// that lands on empty space is still distinguished from one that
    /// starts a real drag, purely by how far the touch actually moved.
    private var spawnGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(space))
            .onEnded { value in
                let dx = value.translation.width
                let dy = value.translation.height
                guard sqrt(dx * dx + dy * dy) < 12 else { return }
                simulation.spawnBlob(near: value.location)
            }
    }
}

/// Renders a single blob as a physical translucent object — native SwiftUI
/// `Material` for the body (so it genuinely shows whatever is behind it,
/// including other blobs), a faint internal tint, and a soft specular
/// highlight for roundness. Deliberately not `.glassEffect` — that API is
/// for the app's actual UI controls (the mode selector), not for objects
/// living inside a scene.
private struct VoidBlobView: View {
    let blob: VoidBlob

    private var displayScale: CGFloat {
        1.0 + blob.pulseAmount * 0.14 + (blob.isDragged ? 0.06 : 0)
    }

    var body: some View {
        Circle()
            .fill(.ultraThinMaterial)
            .overlay {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [blob.color.opacity(blob.isDragged ? 0.28 : 0.16), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: blob.radius
                        )
                    )
                    .allowsHitTesting(false)
            }
            .overlay {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.3), Color.white.opacity(0)],
                            center: UnitPoint(x: 0.32, y: 0.26),
                            startRadius: 0,
                            endRadius: blob.radius * 0.85
                        )
                    )
                    .blendMode(.plusLighter)
                    .allowsHitTesting(false)
            }
            .overlay {
                Circle()
                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 0.75)
                    .allowsHitTesting(false)
            }
            .frame(width: blob.radius * 2, height: blob.radius * 2)
            .scaleEffect(displayScale)
            .contentShape(Circle())
            .animation(.easeOut(duration: 0.25), value: blob.isDragged)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VoidEnvironmentView(reduceMotion: false)
    }
}
