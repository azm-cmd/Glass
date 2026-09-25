import SwiftUI

/// Drives the VOID scene: seeding, per-frame physics (ambient drift,
/// mutual attraction, soft collision, soft boundaries, drag/momentum,
/// long-press pulse), and blob spawning.
///
/// Plain reference type (not `ObservableObject`) on purpose — it is
/// stepped directly from inside a `TimelineView` closure every frame, so
/// there is no need to route mutations through Combine/`@Published`, and
/// no observation-tracking overhead on per-blob mutations that happen
/// every frame.
final class VoidSimulation {
    private(set) var blobs: [VoidBlob] = []

    let maxBlobCount = 8
    private let startingBlobCount = 4

    private var lastTick: Date?

    // MARK: - Frame step

    func seedIfNeeded(size: CGSize) {
        guard blobs.isEmpty, size.width > 1, size.height > 1 else { return }

        for i in 0..<startingBlobCount {
            let angle = (Double(i) / Double(startingBlobCount)) * 2 * Double.pi
            let distance = min(size.width, size.height) * 0.22
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let position = CGPoint(
                x: center.x + CGFloat(cos(angle)) * distance,
                y: center.y + CGFloat(sin(angle)) * distance
            )

            blobs.append(
                VoidBlob(
                    id: UUID(),
                    position: position,
                    velocity: CGVector(dx: .random(in: -8...8), dy: .random(in: -8...8)),
                    radius: .random(in: 38...56),
                    color: VoidBlob.palette[i % VoidBlob.palette.count],
                    phase: Double(i) * 1.9
                )
            )
        }
    }

    func tick(now: Date, size: CGSize, reduceMotion: Bool) {
        defer { lastTick = now }

        guard let last = lastTick, size.width > 1, size.height > 1 else { return }

        let dt = min(now.timeIntervalSince(last), 1.0 / 30.0)
        guard dt > 0 else { return }

        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let time = now.timeIntervalSinceReferenceDate
        let wanderStrength: CGFloat = reduceMotion ? 1.2 : 7.0
        let attractStrength: CGFloat = reduceMotion ? 1.0 : 3.2
        let damping: CGFloat = 0.94

        for i in blobs.indices {
            var blob = blobs[i]

            if !blob.isDragged {
                // Ambient wander: a slow per-blob sine/cosine drift so the
                // scene never fully settles, even untouched.
                let wanderX = sin(time * 0.55 + blob.phase)
                let wanderY = cos(time * 0.47 + blob.phase * 1.3)
                blob.velocity.dx += CGFloat(wanderX) * wanderStrength * CGFloat(dt)
                blob.velocity.dy += CGFloat(wanderY) * wanderStrength * CGFloat(dt)

                // Mutual attraction + soft collision repulsion.
                var ax: CGFloat = 0
                var ay: CGFloat = 0
                for j in blobs.indices where j != i {
                    let other = blobs[j]
                    let dx = other.position.x - blob.position.x
                    let dy = other.position.y - blob.position.y
                    let distance = max(sqrt(dx * dx + dy * dy), 1)
                    let combinedRadius = blob.radius + other.radius

                    if distance < combinedRadius * 0.86 {
                        let overlap = combinedRadius * 0.86 - distance
                        let push: CGFloat = 26
                        ax -= (dx / distance) * overlap * push * CGFloat(dt)
                        ay -= (dy / distance) * overlap * push * CGFloat(dt)
                    } else if distance < 260 {
                        ax += (dx / distance) * attractStrength * CGFloat(dt)
                        ay += (dy / distance) * attractStrength * CGFloat(dt)
                    }
                }

                // Gentle pull back toward center so the composition stays
                // roughly on screen instead of drifting to a corner.
                let centerPull: CGFloat = 0.06
                ax += (center.x - blob.position.x) * centerPull * CGFloat(dt)
                ay += (center.y - blob.position.y) * centerPull * CGFloat(dt)

                blob.velocity.dx += ax
                blob.velocity.dy += ay

                blob.velocity.dx *= damping
                blob.velocity.dy *= damping

                blob.position.x += blob.velocity.dx * CGFloat(dt)
                blob.position.y += blob.velocity.dy * CGFloat(dt)

                applySoftBoundary(to: &blob, size: size, dt: CGFloat(dt))
            }

            // Long-press pulse: rides a sine wave while held, decays after release.
            if blob.isPulsing {
                blob.pulsePhase += dt
                let wave = 0.5 + 0.5 * sin(blob.pulsePhase * 7)
                blob.pulseAmount = CGFloat(wave)
            } else if blob.pulseAmount > 0 {
                blob.pulseAmount = max(0, blob.pulseAmount - CGFloat(dt) * 2.2)
                blob.pulsePhase = 0
            }

            blobs[i] = blob
        }
    }

    private func applySoftBoundary(to blob: inout VoidBlob, size: CGSize, dt: CGFloat) {
        let margin = blob.radius
        let springStrength: CGFloat = 5

        if blob.position.x < margin {
            blob.velocity.dx += (margin - blob.position.x) * springStrength * dt
        } else if blob.position.x > size.width - margin {
            blob.velocity.dx -= (blob.position.x - (size.width - margin)) * springStrength * dt
        }

        if blob.position.y < margin {
            blob.velocity.dy += (margin - blob.position.y) * springStrength * dt
        } else if blob.position.y > size.height - margin {
            blob.velocity.dy -= (blob.position.y - (size.height - margin)) * springStrength * dt
        }

        // Hard safety clamp with generous overshoot allowance so a strong
        // flick can never send a blob permanently off screen, without the
        // boundary reading as a rigid wall in ordinary use.
        let slack = blob.radius * 0.4
        blob.position.x = min(max(blob.position.x, -slack), size.width + slack)
        blob.position.y = min(max(blob.position.y, -slack), size.height + slack)
    }

    // MARK: - Touch interaction

    func beginDrag(id: UUID) {
        guard let index = blobs.firstIndex(where: { $0.id == id }) else { return }
        blobs[index].isDragged = true
        blobs[index].velocity = .zero
    }

    func updateDrag(id: UUID, to location: CGPoint) {
        guard let index = blobs.firstIndex(where: { $0.id == id }) else { return }
        blobs[index].position = location
    }

    func endDrag(id: UUID, location: CGPoint, predictedEndLocation: CGPoint) {
        guard let index = blobs.firstIndex(where: { $0.id == id }) else { return }
        blobs[index].isDragged = false

        let momentumScale: CGFloat = 2.0
        let dx = (predictedEndLocation.x - location.x) * momentumScale
        let dy = (predictedEndLocation.y - location.y) * momentumScale
        blobs[index].velocity = CGVector(dx: dx, dy: dy)
    }

    func setPulsing(id: UUID, active: Bool) {
        guard let index = blobs.firstIndex(where: { $0.id == id }) else { return }
        blobs[index].isPulsing = active
    }

    func spawnBlob(near point: CGPoint) {
        guard blobs.count < maxBlobCount else { return }

        blobs.append(
            VoidBlob(
                id: UUID(),
                position: point,
                velocity: CGVector(dx: .random(in: -16...16), dy: .random(in: -16...16)),
                radius: .random(in: 22...34),
                color: VoidBlob.palette.randomElement() ?? VoidBlob.palette[0],
                phase: Double.random(in: 0..<(2 * Double.pi))
            )
        )
    }
}
