import StoreKit
import UIKit

/// Requests an App Store review at a genuinely positive moment (level-up, streak milestone),
/// throttled so the system prompt is never shown too often. Apple already rate-limits
/// `requestReview`, but we add our own gate: at least a few positive events first, and
/// at most once per ~120 days.
@MainActor
enum ReviewPromptService {
    private static let lastPromptKey = "maxx.lastReviewPromptDate"
    private static let eventCountKey = "maxx.positiveEventCount"
    private static let minEvents = 3
    private static let minDaysBetweenPrompts = 120

    /// Record that something good happened (level-up, badge, streak milestone).
    static func registerPositiveEvent() {
        let defaults = UserDefaults.standard
        defaults.set(defaults.integer(forKey: eventCountKey) + 1, forKey: eventCountKey)
    }

    /// Ask for a review if the user has had enough positive moments and we haven't asked recently.
    static func requestIfAppropriate() {
        let defaults = UserDefaults.standard

        guard defaults.integer(forKey: eventCountKey) >= minEvents else { return }

        if let last = defaults.object(forKey: lastPromptKey) as? Date {
            let days = Calendar.current.dateComponents([.day], from: last, to: .now).day ?? 0
            if days < minDaysBetweenPrompts { return }
        }

        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }

        AppStore.requestReview(in: scene)
        defaults.set(Date.now, forKey: lastPromptKey)
    }
}
