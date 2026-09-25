import SwiftUI

/// A single glass body in the VOID physics playground. Pure data — all
/// motion lives in `VoidSimulation`, all rendering lives in
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

    static let palette: [Color] = [
        Color(red: 0.64, green: 0.50, blue: 1.00),
        Color(red: 0.52, green: 0.66, blue: 1.00),
        Color(red: 0.78, green: 0.58, blue: 0.98),
        Color(red: 0.46, green: 0.62, blue: 0.98),
        Color(red: 0.70, green: 0.52, blue: 1.00),
    ]
}
