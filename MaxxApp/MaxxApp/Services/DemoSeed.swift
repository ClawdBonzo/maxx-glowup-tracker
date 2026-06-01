import Foundation
import SwiftData

#if DEBUG
/// DEBUG-only aspirational demo data for App Store screenshots.
/// Triggered by launch argument `-screenshotMode`. Wipes existing data and seeds
/// a "best foot forward" state: active streak, Gold level, unlocked badges,
/// completed routines, and 30 days of rising daily logs for the analytics charts.
enum DemoSeed {
    static var isScreenshotMode: Bool {
        ProcessInfo.processInfo.arguments.contains("-screenshotMode")
    }

    @MainActor
    static func seed(_ context: ModelContext) {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)

        // Wipe existing
        try? context.delete(model: UserProfile.self)
        try? context.delete(model: Routine.self)
        try? context.delete(model: DailyLog.self)
        try? context.delete(model: GamificationState.self)
        try? context.delete(model: Quest.self)
        try? context.delete(model: Badge.self)

        // MARK: Profile — premium, mid-journey, strong streak
        let profile = UserProfile(
            displayName: "Alex",
            gender: Gender.male.rawValue,
            age: 24,
            primaryGoal: GlowUpGoal.totalTransformation.rawValue,
            focusAreas: [GlowUpCategory.skin.rawValue, GlowUpCategory.faceStructure.rawValue,
                         GlowUpCategory.fitness.rawValue, GlowUpCategory.hair.rawValue],
            commitmentLevel: CommitmentLevel.dedicated.rawValue,
            hasCompletedOnboarding: true,
            isPremium: true
        )
        profile.currentStreak = 14
        profile.longestStreak = 21
        profile.totalCheckIns = 47
        profile.glowScore = 82
        profile.lastCheckInDate = today
        profile.createdAt = cal.date(byAdding: .day, value: -64, to: today) ?? today
        context.insert(profile)

        // MARK: Routines — defaults, with completions building a 14-day streak
        let routines = Routine.defaultRoutines()
        for (i, r) in routines.enumerated() {
            r.sortOrder = i
            // most routines completed for the last 14 days
            if i < 5 {
                r.completedDates = (0..<14).compactMap { cal.date(byAdding: .day, value: -$0, to: today) }
            } else if i < 7 {
                r.completedDates = (1..<10).compactMap { cal.date(byAdding: .day, value: -$0, to: today) }
            }
            context.insert(r)
        }

        // MARK: Gamification — Gold level
        let gam = GamificationState()
        gam.totalXP = 1850
        gam.currentLevel = 10
        gam.currentStreak = 14
        gam.longestStreak = 21
        gam.totalQuestsCompleted = 38
        gam.totalBadgesUnlocked = 3
        context.insert(gam)

        // MARK: Quests — 2 completed, 1 active
        let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!
        let q1 = Quest(type: .daily, title: String(localized: "quest.morning.title", defaultValue: "Morning Routine"),
                       description: String(localized: "quest.morning.desc", defaultValue: "Complete any morning habit"),
                       icon: "🌅", xpReward: 50, targetDate: tomorrow)
        q1.complete()
        let q2 = Quest(type: .daily, title: String(localized: "quest.photo.title", defaultValue: "Progress Photo"),
                       description: String(localized: "quest.photo.desc", defaultValue: "Take a progress photo"),
                       icon: "📸", xpReward: 75, targetDate: tomorrow)
        q2.complete()
        let q3 = Quest(type: .daily, title: String(localized: "quest.triple.title", defaultValue: "Triple Habits"),
                       description: String(localized: "quest.triple.desc", defaultValue: "Complete 3 routines today"),
                       icon: "🔥", xpReward: 100, targetDate: tomorrow)
        [q1, q2, q3].forEach { context.insert($0) }

        // MARK: Badges — first 3 unlocked
        let badges: [(String, String, String, BadgeTier, BadgeRequirement, Bool)] = [
            ("First Step", "Complete your first daily routine", "👣", .bronze, .routinesCompleted(1), true),
            ("Week Warrior", "Maintain a 7-day streak", "⚔️", .silver, .streakDays(7), true),
            ("Transformation", "Upload 10 progress photos", "📸", .gold, .photosUploaded(10), true),
            ("Jawline God", "Reach Diamond Jawline", "💎", .diamond, .levelReached(20), false),
        ]
        for (name, desc, icon, tier, req, unlocked) in badges {
            let b = Badge(name: name, description: desc, icon: icon, tier: tier, requirement: req)
            if unlocked { b.unlockedDate = cal.date(byAdding: .day, value: -Int.random(in: 1...10), to: today) }
            context.insert(b)
        }

        // MARK: Daily logs — 30 days, rising glow score & ratings for charts
        let routineIDs = routines.prefix(5).map(\.id)
        for dayOffset in 0..<30 {
            guard let date = cal.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let log = DailyLog(date: date)
            // ratings trend upward toward today (dayOffset 0 = today = best)
            let t = Double(29 - dayOffset) / 29.0   // 0 (oldest) → 1 (today)
            let base = 3.0 + t * 1.8                 // 3.0 → 4.8
            func r(_ jitter: Double) -> Int { max(2, min(5, Int((base + jitter).rounded()))) }
            log.overallMood = r(0.1)
            log.skinRating = r(0.0)
            log.hairRating = r(-0.2)
            log.fitnessRating = r(0.2)
            log.confidenceRating = r(0.3)
            log.completedRoutineIDs = Array(routineIDs.prefix(dayOffset % 5 == 0 ? 3 : 5))
            log.glowScore = min(100, 55 + t * 35)   // 55 → 90
            context.insert(log)
        }

        try? context.save()
    }
}
#endif
