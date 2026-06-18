import SwiftUI

extension Color {
    static let appBackground = Color(
        light: Color(red: 0.98, green: 0.96, blue: 0.93),
        dark:  Color(red: 0.11, green: 0.10, blue: 0.09)
    )
    static let cardBackground = Color(
        light: .white,
        dark:  Color(red: 0.16, green: 0.15, blue: 0.14)
    )
    static let accentTerracotta = Color(red: 0.85, green: 0.45, blue: 0.35)
    static let accentSage       = Color(red: 0.56, green: 0.68, blue: 0.55)
    static let accentAmber      = Color(red: 0.93, green: 0.72, blue: 0.42)
    static let accentBlush      = Color(red: 0.93, green: 0.78, blue: 0.78)
    static let textPrimary = Color(
        light: .black,
        dark:  Color(red: 0.94, green: 0.93, blue: 0.91)
    )
    static let textSecondary = Color(
        light: Color.black.opacity(0.45),
        dark:  Color(red: 0.94, green: 0.93, blue: 0.91).opacity(0.5)
    )
    static let cardStroke = Color(
        light: Color.black.opacity(0.06),
        dark:  Color.white.opacity(0.08)
    )

    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(
            dynamicProvider: { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(dark)
                    : UIColor(light)
            }
        ))
    }
}

struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) var scheme
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(16)
            .shadow(
                color: scheme == .dark
                    ? Color.black.opacity(0.35)
                    : Color.black.opacity(0.06),
                radius: 10, x: 0, y: 3
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Haptic helper
func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    UIImpactFeedbackGenerator(style: style).impactOccurred()
}

// MARK: - Shake modifier
struct ShakeModifier: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// MARK: - Press scale button style
struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}


//latest
