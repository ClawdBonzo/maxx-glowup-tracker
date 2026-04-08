import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var displayName: String
    var gender: String?
    var age: Int?
    var primaryGoal: String?
    var focusAreas: [String]
    var commitmentLevel: String?
    var hasCompletedOnboarding: Bool
    var isPremium: Bool
    var createdAt: Date
    var currentStreak: Int
    var longestStreak: Int
    var lastCheckInDate: Date?
    var totalCheckIns: Int
    var glowScore: Double

    init(
        displayName: String = "",
        gender: String? = nil,
        age: Int? = nil,
        primaryGoal: String? = nil,
        focusAreas: [String] = [],
        commitmentLevel: String? = nil,
        hasCompletedOnboarding: Bool = false,
        isPremium: Bool = false
    ) {
        self.id = UUID()
        self.displayName = displayName
        self.gender = gender
        self.age = age
        self.primaryGoal = primaryGoal
        self.focusAreas = focusAreas
        self.commitmentLevel = commitmentLevel
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.isPremium = isPremium
        self.createdAt = .now
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastCheckInDate = nil
        self.totalCheckIns = 0
        self.glowScore = 0
    }

    var parsedGender: Gender? {
        guard let gender else { return nil }
        return Gender(rawValue: gender)
    }

    var parsedGoal: GlowUpGoal? {
        guard let primaryGoal else { return nil }
        return GlowUpGoal(rawValue: primaryGoal)
    }

    var parsedCommitment: CommitmentLevel? {
        guard let commitmentLevel else { return nil }
        return CommitmentLevel(rawValue: commitmentLevel)
    }

    var parsedFocusAreas: [GlowUpCategory] {
        focusAreas.compactMap { GlowUpCategory(rawValue: $0) }
    }

    var daysSinceJoined: Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: .now).day ?? 0
    }

    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        if let lastDate = lastCheckInDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysBetween == 1 {
                currentStreak += 1
            } else if daysBetween > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }

        lastCheckInDate = .now
        totalCheckIns += 1
    }
}
