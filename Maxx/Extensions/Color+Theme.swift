import SwiftUI

extension Color {
    // MARK: - Primary Brand Colors
    static let maxxPrimary = Color(hex: "6C5CE7")
    static let maxxSecondary = Color(hex: "A29BFE")
    static let maxxAccent = Color(hex: "FD79A8")
    static let maxxGold = Color(hex: "FDCB6E")

    // MARK: - Background
    static let maxxBackground = Color(hex: "0A0A0F")
    static let maxxSurface = Color(hex: "1A1A2E")
    static let maxxSurfaceLight = Color(hex: "25253D")
    static let maxxCard = Color(hex: "16213E")

    // MARK: - Text
    static let maxxTextPrimary = Color.white
    static let maxxTextSecondary = Color(hex: "B2BEC3")
    static let maxxTextMuted = Color(hex: "636E72")

    // MARK: - Status
    static let maxxSuccess = Color(hex: "00B894")
    static let maxxWarning = Color(hex: "FDCB6E")
    static let maxxError = Color(hex: "E17055")

    // MARK: - Category Colors
    static let skinColor = Color(hex: "74B9FF")
    static let hairColor = Color(hex: "A29BFE")
    static let fitnessColor = Color(hex: "FF7675")
    static let faceColor = Color(hex: "FD79A8")
    static let styleColor = Color(hex: "FDCB6E")
    static let groomingColor = Color(hex: "00CEC9")
    static let postureColor = Color(hex: "55EFC4")
    static let teethColor = Color(hex: "FFEAA7")

    // MARK: - Gradients
    static let maxxGradient = LinearGradient(
        colors: [maxxPrimary, maxxAccent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let maxxGoldGradient = LinearGradient(
        colors: [Color(hex: "F9CA24"), Color(hex: "F0932B")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let maxxDarkGradient = LinearGradient(
        colors: [maxxBackground, maxxSurface],
        startPoint: .top,
        endPoint: .bottom
    )

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
        case .skin: .skinColor
        case .hair: .hairColor
        case .fitness: .fitnessColor
        case .faceStructure: .faceColor
        case .style: .styleColor
        case .grooming: .groomingColor
        case .posture: .postureColor
        case .teeth: .teethColor
        }
    }
}
