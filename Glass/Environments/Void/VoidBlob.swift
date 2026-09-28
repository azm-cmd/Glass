import SwiftUI

/// A single translucent physical object in the VOID playground. Pure
/// data — all motion lives in `VoidSimulation`, all rendering lives in
/// `VoidEnvironmentView`.
struct VoidBlob: Identifiable {
    let id: UUID
    var position: CGPoint
    var velocity: CGVector
    var radius: CGFloat
    var color: Color

    /// Per-blob offset so ambient drift doesn't move every blob in lockstep.
    var phase: Double

    /// True while the user's finger is actively driving this blob's position.
    var isDragged = false

    /// True while a long press on this blob is being held.
    var isPulsing = false

    /// Running clock for the pulse waveform while `isPulsing` is true.
    var pulsePhase: Double = 0

    /// 0...1 display amount, eased in while pulsing and eased back out after.
    var pulseAmount: CGFloat = 0

    /// Deliberately low-saturation — these read as faint, cool internal
    /// light rather than "colored balls." Color is a hint, not a fill.
    static let palette: [Color] = [
        Color(hue: 0.62, saturation: 0.14, brightness: 0.97),
        Color(hue: 0.58, saturation: 0.10, brightness: 0.95),
        Color(hue: 0.66, saturation: 0.12, brightness: 0.96),
        Color.white,
    ]
}
