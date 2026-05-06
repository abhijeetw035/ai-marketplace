import SwiftUI

enum Theme {
    static let primary = Color(hex: "#111111")
    static let secondaryText = Color(hex: "#666666")
    static let background = Color.white // #FFFFFF
    static let secondaryBackground = Color(hex: "#F8F9FA")
    static let tertiaryBackground = Color(hex: "#F1F3F5")
    static let accent = Color(hex: "#2563EB")
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let border = Color(hex: "#E0E0E0")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct DesignSystem {
    struct Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let pill: CGFloat = 50
    }
    
    struct Typography {
        static let largeTitle  = Font.largeTitle.weight(.bold)
        static let title       = Font.title2.weight(.bold)
        static let headline    = Font.headline.weight(.semibold)
        static let body        = Font.body
        static let caption     = Font.caption
        static let micro       = Font.caption2
    }
    
    struct Shadow {
        static let card = SwiftUI.Shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        static let button = SwiftUI.Shadow(color: Color(hex: "#2563EB").opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Shadow helper

struct SwiftUI { struct Shadow { let color: Color; let radius: CGFloat; let x: CGFloat; let y: CGFloat } }

// MARK: - Primary Button Style

struct PrimaryButtonStyle: ButtonStyle {
    var isDestructive: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.small + 2)
            .background(isDestructive ? Theme.error : Theme.accent)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .shadow(color: (isDestructive ? Theme.error : Theme.accent).opacity(0.3), radius: 6, x: 0, y: 3)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Scale Press Button Style (for cards)

struct ScalePressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Appear Animation Modifier

struct AppearAnimation: ViewModifier {
    @State private var appeared = false
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(delay)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func appearAnimation(delay: Double = 0) -> some View {
        modifier(AppearAnimation(delay: delay))
    }
}
