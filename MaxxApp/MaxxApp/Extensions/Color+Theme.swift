import SwiftUI

extension Color {
    // MARK: - Primary Brand Colors (Neon Palette)
    static let maxxPrimary   = Color(hex: "8B00FF")   // Neon violet
    static let maxxCyan      = Color(hex: "00F0FF")   // Electric cyan
    static let maxxGold      = Color(hex: "FFD700")   // Hot gold
    static let maxxSecondary = Color(hex: "B040FF")   // Lighter violet
    static let maxxAccent    = Color(hex: "FF3CAC")   // Electric magenta/pink

    // MARK: - Background
    static let maxxBackground   = Color(hex: "08080F")
    static let maxxSurface      = Color(hex: "10101E")
    static let maxxSurfaceLight = Color(hex: "1C1C30")
    static let maxxCard         = Color(hex: "14142A")

    // MARK: - Text
    static let maxxTextPrimary   = Color.white
    static let maxxTextSecondary = Color(hex: "C0B8D8")
    static let maxxTextMuted     = Color(hex: "6B6890")

    // MARK: - Status
    static let maxxSuccess = Color(hex: "00FFB2")   // Neon green
    static let maxxWarning = Color(hex: "FFD700")   // Hot gold
    static let maxxError   = Color(hex: "FF3860")   // Electric red

    // MARK: - Category Colors (vibrant neon)
    static let skinColor     = Color(hex: "00F0FF")  // Electric cyan
    static let hairColor     = Color(hex: "B040FF")  // Neon violet
    static let fitnessColor  = Color(hex: "FF3CAC")  // Electric magenta
    static let faceColor     = Color(hex: "FFD700")  // Hot gold
    static let styleColor    = Color(hex: "FF6B35")  // Electric orange
    static let groomingColor = Color(hex: "00FFB2")  // Neon green
    static let postureColor  = Color(hex: "40E0FF")  // Bright cyan
    static let teethColor    = Color(hex: "FFFFFF")  // Pure white

    // MARK: - Core Gradients
    static let maxxGradient = LinearGradient(
        colors: [maxxPrimary, maxxCyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let maxxTriGradient = LinearGradient(
        colors: [maxxPrimary, maxxCyan, maxxGold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let maxxGoldGradient = LinearGradient(
        colors: [Color(hex: "FFD700"), Color(hex: "FF8C00")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let maxxDarkGradient = LinearGradient(
        colors: [maxxBackground, maxxSurface],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Neon Glow Colors (for shadow effects)
    static let neonVioletGlow = Color(hex: "8B00FF")
    static let neonCyanGlow   = Color(hex: "00F0FF")
    static let neonGoldGlow   = Color(hex: "FFD700")
    static let neonPinkGlow   = Color(hex: "FF3CAC")

    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static func categoryColor(for category: GlowUpCategory) -> Color {
        switch category {
        case .skin:          .skinColor
        case .hair:          .hairColor
        case .fitness:       .fitnessColor
        case .faceStructure: .faceColor
        case .style:         .styleColor
        case .grooming:      .groomingColor
        case .posture:       .postureColor
        case .teeth:         .teethColor
        }
    }
}
