import SwiftUI
import UIKit

/// The floating Liquid Glass mode selector. A capsule of native glass
/// hosts five compact icons; the selected icon carries its own tinted
/// glass highlight that morphs between icons via `matchedGeometryEffect`.
/// Tapping an icon or dragging horizontally across the bar both change
/// the mode, with a light haptic tick on every change.
struct ModeSelectorView: View {
    @Binding var selectedMode: EnvironmentMode
    let reduceMotion: Bool

    @Namespace private var glassNamespace
    @State private var dragStartIndex: Int?

    private let modes = EnvironmentMode.allCases
    private let iconDiameter: CGFloat = 50
    private let iconSpacing: CGFloat = 4
    @State private var feedback = UIImpactFeedbackGenerator(style: .light)

    private var stepWidth: CGFloat { iconDiameter + iconSpacing }

    var body: some View {
        GlassEffectContainer(spacing: 20) {
            HStack(spacing: iconSpacing) {
                ForEach(modes) { mode in
                    iconButton(for: mode)
                }
            }
            .padding(8)
            .glassEffect(.regular, in: .capsule)
        }
        .simultaneousGesture(dragGesture)
        .onAppear { feedback.prepare() }
    }

    private func iconButton(for mode: EnvironmentMode) -> some View {
        let isSelected = mode == selectedMode

        return Button {
            select(mode)
        } label: {
            Image(systemName: mode.symbolName)
                .font(.system(size: 18, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
                .frame(width: iconDiameter, height: iconDiameter)
                .background {
                    if isSelected {
                        Circle()
                            .glassEffect(
                                .regular.tint(mode.accentColor.opacity(0.55)).interactive(),
                                in: .circle
                            )
                            .matchedGeometryEffect(id: "selectionHighlight", in: glassNamespace)
                    }
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mode.title)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { value in
                if dragStartIndex == nil {
                    dragStartIndex = modes.firstIndex(of: selectedMode) ?? 0
                }
                guard let startIndex = dragStartIndex else { return }
                let delta = Int((value.translation.width / stepWidth).rounded())
                let targetIndex = min(modes.count - 1, max(0, startIndex + delta))
                let mode = modes[targetIndex]
                if mode != selectedMode {
                    select(mode)
                }
            }
            .onEnded { _ in
                dragStartIndex = nil
            }
    }

    private func select(_ mode: EnvironmentMode) {
        guard mode != selectedMode else { return }

        let animation: Animation = reduceMotion
            ? .easeInOut(duration: 0.2)
            : .spring(response: 0.45, dampingFraction: 0.72)

        withAnimation(animation) {
            selectedMode = mode
        }

        feedback.impactOccurred(intensity: reduceMotion ? 0.4 : 0.85)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ModeSelectorView(selectedMode: .constant(.void), reduceMotion: false)
    }
}
