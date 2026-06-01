import Foundation
import SwiftData

@Observable
@MainActor
final class GamificationViewModel {
    var gamificationState: GamificationState
    var quests: [Quest] = []
    var badges: [Badge] = []
    var showLevelUpAnimation = false
    var showQuestCompletionAnimation = false
    var showBadgeUnlockAnimation = false
    var selectedBadge: Badge?

    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.gamificationState = GamificationState()
        loadOrCreateGamificationState()
        loadQuests()
        loadBadges()
        initializeDefaultBadges()
    }

    // MARK: - Initialization

    private func loadOrCreateGamificationState() {
        let descriptor = FetchDescriptor<GamificationState>()
        if let existing = try? modelContext.fetch(descriptor).first {
            gamificationState = existing
        } else {
            modelContext.insert(gamificationState)
            try? modelContext.save()
        }
    }

    private func loadQuests() {
        let descriptor = FetchDescriptor<Quest>()
        quests = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func loadBadges() {
        let descriptor = FetchDescriptor<Badge>()
        badges = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func initializeDefaultBadges() {
        if badges.isEmpty {
            let defaultBadges = [
                Badge(
                    name: String(localized: "badge.firstStep.name", defaultValue: "First Step"),
                    description: String(localized: "badge.firstStep.desc", defaultValue: "Complete your first daily routine"),
                    icon: "👣",
                    tier: .bronze,
                    requirement: .routinesCompleted(1)
                ),
                Badge(
                    name: String(localized: "badge.weekWarrior.name", defaultValue: "Week Warrior"),
                    description: String(localized: "badge.weekWarrior.desc", defaultValue: "Maintain a 7-day streak"),
                    icon: "⚔️",
                    tier: .silver,
                    requirement: .streakDays(7)
                ),
                Badge(
                    name: String(localized: "badge.transformation.name", defaultValue: "Transformation"),
                    description: String(localized: "badge.transformation.desc", defaultValue: "Upload 10 progress photos"),
                    icon: "📸",
                    tier: .gold,
                    requirement: .photosUploaded(10)
                ),
                Badge(
                    name: String(localized: "badge.jawlineGod.name", defaultValue: "Jawline God"),
                    description: String(localized: "badge.jawlineGod.desc", defaultValue: "Reach Diamond Jawline"),
                    icon: "💎",
                    tier: .diamond,
                    requirement: .levelReached(20)
                ),
            ]

            for badge in defaultBadges {
                modelContext.insert(badge)
            }
            badges = defaultBadges
            try? modelContext.save()
        }
    }

    // MARK: - XP & Level Up

    func addXP(_ amount: Int, reason: String = "") {
        let (leveledUp, newLevel) = gamificationState.addXP(amount)

        if leveledUp {
            showLevelUpAnimation = true
            HapticService.levelUp()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showLevelUpAnimation = false
            }
        }

        try? modelContext.save()
    }

    func currentLevelInfo() -> (level: JawlineLevel, progress: Double) {
        let level = JawlineLevel.forXP(gamificationState.totalXP)
        let (current, required) = level.xpProgressToNext()
        let progress = required > current ? Double(gamificationState.totalXP - current) / Double(required - current) : 1.0
        return (level: level, progress: min(progress, 1.0))
    }

    // MARK: - Quests

    func createDailyQuests() {
        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let dailyQuests = [
            Quest(type: .daily, title: String(localized: "quest.morning.title", defaultValue: "Morning Routine"), description: String(localized: "quest.morning.desc", defaultValue: "Complete any morning habit"), icon: "🌅", xpReward: 50, targetDate: tomorrow),
            Quest(type: .daily, title: String(localized: "quest.photo.title", defaultValue: "Progress Photo"), description: String(localized: "quest.photo.desc", defaultValue: "Take a progress photo"), icon: "📸", xpReward: 75, targetDate: tomorrow),
            Quest(type: .daily, title: String(localized: "quest.triple.title", defaultValue: "Triple Habits"), description: String(localized: "quest.triple.desc", defaultValue: "Complete 3 routines today"), icon: "🔥", xpReward: 100, targetDate: tomorrow),
        ]

        for quest in dailyQuests {
            modelContext.insert(quest)
        }
        quests.append(contentsOf: dailyQuests)
        try? modelContext.save()
    }

    func completeQuest(_ quest: Quest) {
        quest.complete()
        addXP(quest.xpReward, reason: "Quest: \(quest.title)")
        gamificationState.totalQuestsCompleted += 1

        showQuestCompletionAnimation = true
        HapticService.questComplete()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showQuestCompletionAnimation = false
        }

        try? modelContext.save()
        checkBadgeProgress()
    }

    func getActiveDailyQuests() -> [Quest] {
        let today = Calendar.current.startOfDay(for: .now)
        return quests.filter { q in
            q.type == .daily &&
                Calendar.current.startOfDay(for: q.targetDate) == today &&
                !q.isCompleted
        }
    }

    func getCompletedDailyQuests() -> [Quest] {
        let today = Calendar.current.startOfDay(for: .now)
        return quests.filter { q in
            q.type == .daily &&
                Calendar.current.startOfDay(for: q.targetDate) == today &&
                q.isCompleted
        }
    }

    // MARK: - Streaks & Multipliers

    func updateDailyStreak() {
        gamificationState.resetStreakIfNeeded()
        gamificationState.incrementStreak()

        let multiplier = min(1 + Double(gamificationState.currentStreak) / 10.0, 2.5)
        let bonusXP = Int(Double(25) * multiplier)
        addXP(bonusXP, reason: "Daily streak bonus (\(gamificationState.currentStreak) days)")

        if gamificationState.currentStreak % 7 == 0 {
            HapticService.streakMilestone()
        }

        try? modelContext.save()
    }

    var streakMultiplier: Double {
        1 + Double(min(gamificationState.currentStreak, 20)) * 0.05
    }

    // MARK: - Badges

    func checkBadgeProgress() {
        for badge in badges where !badge.isUnlocked {
            if shouldUnlock(badge) {
                unlockBadge(badge)
            }
        }
    }

    private func shouldUnlock(_ badge: Badge) -> Bool {
        switch badge.requirement {
        case .streakDays(let target):
            return gamificationState.currentStreak >= target
        case .totalXP(let target):
            return gamificationState.totalXP >= target
        case .routinesCompleted(let target):
            return gamificationState.totalQuestsCompleted >= target
        case .photosUploaded:
            return false // Would be tracked separately by progress photos
        case .levelReached(let target):
            return JawlineLevel.forXP(gamificationState.totalXP).rawValue >= target
        }
    }

    func unlockBadge(_ badge: Badge) {
        badge.unlockedDate = .now
        gamificationState.totalBadgesUnlocked += 1
        selectedBadge = badge
        showBadgeUnlockAnimation = true
        HapticService.badgeUnlock()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.showBadgeUnlockAnimation = false
        }

        try? modelContext.save()
    }

    func getUnlockedBadges() -> [Badge] {
        badges.filter { $0.isUnlocked }.sorted { ($0.unlockedDate ?? .now) > ($1.unlockedDate ?? .now) }
    }

    func getLockedBadges() -> [Badge] {
        badges.filter { !$0.isUnlocked }
    }
}
