import SwiftUI
import UIKit

/// The floating Liquid Glass mode selector: one native glass capsule
/// housing five SF Symbol icons. Selection is shown by a plain (colorless)
/// glass highlight that slides between icons, plus a brightness/weight
/// change on the icon itself — never a tinted "badge." All color comes
/// from the environment behind the glass, not from this control.
struct ModeSelectorView: View {
    @Binding var selectedMode: EnvironmentMode
    let reduceMotion: Bool

    @Namespace private var glassNamespace
    @State private var dragStartIndex: Int?
    @State private var feedback = UIImpactFeedbackGenerator(style: .light)

    private let modes = EnvironmentMode.allCases
    private let iconDiameter: CGFloat = 44
    private let iconSpacing: CGFloat = 6

    private var stepWidth: CGFloat { iconDiameter + iconSpacing }

    var body: some View {
        GlassEffectContainer(spacing: 18) {
            HStack(spacing: iconSpacing) {
                ForEach(modes) { mode in
                    iconButton(for: mode)
                }
            }
            .padding(9)
            .glassEffect(.regular.interactive(), in: .capsule)
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
                .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.45))
                .frame(width: iconDiameter, height: iconDiameter)
                .background {
                    if isSelected {
                        Circle()
                            .glassEffect(.regular.interactive(), in: .circle)
                            .matchedGeometryEffect(id: "selection", in: glassNamespace)
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
            : .spring(response: 0.5, dampingFraction: 0.8)

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
