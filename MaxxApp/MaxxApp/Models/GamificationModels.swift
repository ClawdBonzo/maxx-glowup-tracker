import Foundation
import SwiftData

// MARK: - XP & Level System

enum JawlineLevel: Int, Codable, CaseIterable, Identifiable {
    case bronzeJawline = 1
    case silverJawline = 5
    case goldJawline = 10
    case platinumJawline = 15
    case diamondJawline = 20

    var id: Int { rawValue }
    var displayName: String {
        switch self {
        case .bronzeJawline: "Bronze Jawline"
        case .silverJawline: "Silver Jawline"
        case .goldJawline: "Gold Jawline"
        case .platinumJawline: "Platinum Jawline"
        case .diamondJawline: "Diamond Jawline"
        }
    }

    var emoji: String {
        switch self {
        case .bronzeJawline: "🥉"
        case .silverJawline: "🥈"
        case .goldJawline: "🥇"
        case .platinumJawline: "💎"
        case .diamondJawline: "✨"
        }
    }

    var xpRequired: Int {
        switch self {
        case .bronzeJawline: 0
        case .silverJawline: 500
        case .goldJawline: 1500
        case .platinumJawline: 3500
        case .diamondJawline: 7000
        }
    }

    static func forXP(_ xp: Int) -> JawlineLevel {
        JawlineLevel.allCases.reversed().first { $0.xpRequired <= xp } ?? .bronzeJawline
    }

    func xpProgressToNext() -> (current: Int, required: Int) {
        let nextLevel = JawlineLevel.allCases.first { $0.rawValue > self.rawValue }
        let nextXP = nextLevel?.xpRequired ?? Int.max
        let currentXP = self.xpRequired
        return (current: currentXP, required: nextXP)
    }
}

// MARK: - Quests

enum QuestType: String, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
}

@Model
final class Quest {
    var id: UUID
    var type: QuestType
    var title: String
    var details: String
    var icon: String
    var xpReward: Int
    var isCompleted: Bool
    var completedDate: Date?
    var createdDate: Date
    var targetDate: Date // Daily (today), Weekly (end of week)

    init(
        type: QuestType,
        title: String,
        description: String,
        icon: String,
        xpReward: Int,
        targetDate: Date
    ) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.details = description
        self.icon = icon
        self.xpReward = xpReward
        self.isCompleted = false
        self.completedDate = nil
        self.createdDate = .now
        self.targetDate = targetDate
    }

    func complete() {
        isCompleted = true
        completedDate = .now
    }

    var isExpired: Bool {
        Date.now > targetDate && !isCompleted
    }
}

// MARK: - Badges

enum BadgeTier: String, Codable, CaseIterable {
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"
    case diamond = "Diamond"

    var color: String {
        switch self {
        case .bronze: "#CD7F32"
        case .silver: "#C0C0C0"
        case .gold: "#FFD700"
        case .platinum: "#E5E4E2"
        case .diamond: "#B9F2FF"
        }
    }
}

@Model
final class Badge {
    var id: UUID
    var name: String
    var details: String
    var icon: String
    var tier: BadgeTier
    var unlockedDate: Date?
    var requirement: BadgeRequirement

    init(
        name: String,
        description: String,
        icon: String,
        tier: BadgeTier,
        requirement: BadgeRequirement
    ) {
        self.id = UUID()
        self.name = name
        self.details = description
        self.icon = icon
        self.tier = tier
        self.unlockedDate = nil
        self.requirement = requirement
    }

    var isUnlocked: Bool { unlockedDate != nil }
}

enum BadgeRequirement: Codable {
    case streakDays(Int)
    case totalXP(Int)
    case routinesCompleted(Int)
    case photosUploaded(Int)
    case levelReached(Int)

    var displayName: String {
        switch self {
        case .streakDays(let days):
            return "\(days)-Day Streak"
        case .totalXP(let xp):
            return "\(xp) XP Earned"
        case .routinesCompleted(let count):
            return "\(count) Routines Completed"
        case .photosUploaded(let count):
            return "\(count) Progress Photos"
        case .levelReached(let level):
            return "Reach Level \(level)"
        }
    }
}

// MARK: - Gamification State

@Model
final class GamificationState {
    var id: UUID
    var totalXP: Int
    var currentLevel: Int // 1-20
    var currentStreak: Int
    var longestStreak: Int
    var streakLastUpdated: Date
    var totalQuestsCompleted: Int
    var totalBadgesUnlocked: Int
    var lastDailyQuestReset: Date
    var lastWeeklyQuestReset: Date

    init() {
        self.id = UUID()
        self.totalXP = 0
        self.currentLevel = 1
        self.currentStreak = 0
        self.longestStreak = 0
        self.streakLastUpdated = .now
        self.totalQuestsCompleted = 0
        self.totalBadgesUnlocked = 0
        self.lastDailyQuestReset = .now
        self.lastWeeklyQuestReset = .now
    }

    func addXP(_ amount: Int) -> (leveledUp: Bool, newLevel: Int) {
        totalXP += amount
        let oldLevel = currentLevel
        currentLevel = min(JawlineLevel.diamondJawline.rawValue, currentLevel + (totalXP / 500))
        return (leveledUp: currentLevel > oldLevel, newLevel: currentLevel)
    }

    func incrementStreak() {
        currentStreak += 1
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        streakLastUpdated = .now
    }

    func resetStreakIfNeeded() {
        let calendar = Calendar.current
        let daysSinceUpdate = calendar.dateComponents([.day], from: streakLastUpdated, to: .now).day ?? 0

        if daysSinceUpdate > 1 {
            currentStreak = 0
        }
    }
}
