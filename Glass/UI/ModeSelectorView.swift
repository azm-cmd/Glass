import SwiftUI
import UIKit

/// The floating Liquid Glass mode selector: one native glass capsule
/// housing five SF Symbol icons, plus one *persistent* glass circle that
/// slides between icon positions via an animated offset.
///
/// Earlier this used a `Circle` nested inside each icon button's own
/// conditional `.background`, tagged with a shared `glassEffectID`, on
/// the theory that Apple's system would recognize the pair as one shape
/// relocating across a view-hierarchy transition. On an actual device
/// that produced two independent shapes cross-fading in place — a
/// double-circle "ghost," not a morph. The structural difference from
/// Apple's own documented example (where the two `glassEffectID`-tagged
/// views are direct siblings in one `HStack`, not nested separately
/// inside two different parent buttons) is the likely cause. This
/// version keeps exactly one glass circle alive at all times, as a
/// sibling of the icon row rather than owned by any one icon, and
/// animates its position — no insert/remove, so there's nothing to
/// mismatch.
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

    private var selectedIndex: Int {
        modes.firstIndex(of: selectedMode) ?? 0
    }

    var body: some View {
        GlassEffectContainer(spacing: 20) {
            ZStack(alignment: .leading) {
                Circle()
                    .glassEffect(.regular.interactive(), in: .circle)
                    .glassEffectID("selection", in: glassNamespace)
                    .frame(width: iconDiameter, height: iconDiameter)
                    .offset(x: CGFloat(selectedIndex) * stepWidth)
                    .allowsHitTesting(false)

                HStack(spacing: iconSpacing) {
                    ForEach(modes) { mode in
                        iconButton(for: mode)
                    }
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
