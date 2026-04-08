import UIKit

@MainActor
enum HapticService {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    static func success() {
        notification(.success)
    }

    static func error() {
        notification(.error)
    }

    static func lightTap() {
        impact(.light)
    }

    static func heavyTap() {
        impact(.heavy)
    }

    // MARK: - Gamification Haptics

    static func levelUp() {
        let sequence: [(UIImpactFeedbackGenerator.FeedbackStyle, Double)] = [
            (.medium, 0),
            (.heavy, 0.1),
            (.heavy, 0.2),
        ]
        for (style, delay) in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                impact(style)
            }
        }
    }

    static func questComplete() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            selection()
        }
    }

    static func streakMilestone() {
        let sequence: [(UIImpactFeedbackGenerator.FeedbackStyle, Double)] = [
            (.light, 0),
            (.medium, 0.08),
            (.heavy, 0.16),
        ]
        for (style, delay) in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                impact(style)
            }
        }
    }

    static func badgeUnlock() {
        let sequence: [(UIImpactFeedbackGenerator.FeedbackStyle, Double)] = [
            (.heavy, 0),
            (.medium, 0.12),
            (.light, 0.24),
            (.heavy, 0.36),
        ]
        for (style, delay) in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                impact(style)
            }
        }
    }
}
