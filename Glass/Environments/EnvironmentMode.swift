import SwiftUI

/// The five playground environments. This stage only renders a placeholder
/// scene per mode; later work replaces `PlaceholderEnvironmentView` with a
/// dedicated view per case inside `EnvironmentContainerView`.
enum EnvironmentMode: Int, CaseIterable, Identifiable, Hashable {
    case void
    case fluid
    case orbit
    case playground
    case light

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .void: "VOID"
        case .fluid: "FLUID"
        case .orbit: "ORBIT"
        case .playground: "PLAYGROUND"
        case .light: "LIGHT"
        }
    }

    var subtitle: String {
        switch self {
        case .void: "Glass blobs & touch physics"
        case .fluid: "Liquid particles"
        case .orbit: "Glass planetary objects"
        case .playground: "Manipulatable glass objects"
        case .light: "Light & refraction sculpture"
        }
    }

    /// SF Symbols used across the mode selector and environment placeholder.
    var symbolName: String {
        switch self {
        case .void: "moon.stars.fill"
        case .fluid: "drop.fill"
        case .orbit: "atom"
        case .playground: "square.stack.3d.up.fill"
        case .light: "sparkles"
        }
    }

    var accentColor: Color {
        switch self {
        case .void: Color(red: 0.62, green: 0.49, blue: 1.0)
        case .fluid: Color(red: 0.35, green: 0.78, blue: 1.0)
        case .orbit: Color(red: 0.55, green: 0.6, blue: 1.0)
        case .playground: Color(red: 0.42, green: 0.95, blue: 0.8)
        case .light: Color(red: 1.0, green: 0.85, blue: 0.45)
        }
    }
}
