import Foundation
import SwiftData

@Model
final class Routine {
    var id: UUID
    var name: String
    var routineDescription: String
    var category: String
    var icon: String
    var durationMinutes: Int
    var isActive: Bool
    var isPremium: Bool
    var sortOrder: Int
    var completedDates: [Date]
    var createdAt: Date
    var reminderTime: Date?
    var daysOfWeek: [Int]

    init(
        name: String,
        description: String = "",
        category: String,
        icon: String = "checkmark.circle.fill",
        durationMinutes: Int = 5,
        isPremium: Bool = false,
        sortOrder: Int = 0,
        daysOfWeek: [Int] = [1, 2, 3, 4, 5, 6, 7]
    ) {
        self.id = UUID()
        self.name = name
        self.routineDescription = description
        self.category = category
        self.icon = icon
        self.durationMinutes = durationMinutes
        self.isActive = true
        self.isPremium = isPremium
        self.sortOrder = sortOrder
        self.completedDates = []
        self.createdAt = .now
        self.reminderTime = nil
        self.daysOfWeek = daysOfWeek
    }

    var parsedCategory: GlowUpCategory? {
        GlowUpCategory(rawValue: category)
    }

    var isCompletedToday: Bool {
        let today = Calendar.current.startOfDay(for: .now)
        return completedDates.contains { Calendar.current.startOfDay(for: $0) == today }
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: .now)

        if !isCompletedToday {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                return 0
            }
            checkDate = yesterday
        }

        while completedDates.contains(where: { calendar.startOfDay(for: $0) == checkDate }) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }

        return streak
    }

    var isScheduledToday: Bool {
        let weekday = Calendar.current.component(.weekday, from: .now)
        return daysOfWeek.contains(weekday)
    }

    func markCompleted() {
        let today = Calendar.current.startOfDay(for: .now)
        if !completedDates.contains(where: { Calendar.current.startOfDay(for: $0) == today }) {
            completedDates.append(.now)
        }
    }

    func unmarkCompleted() {
        let today = Calendar.current.startOfDay(for: .now)
        completedDates.removeAll { Calendar.current.startOfDay(for: $0) == today }
    }

    static func defaultRoutines() -> [Routine] {
        [
            Routine(name: String(localized: "routine.morningSkincare.name", defaultValue: "Morning Skincare"), description: String(localized: "routine.morningSkincare.desc", defaultValue: "Cleanser → Serum → Moisturizer → SPF"), category: GlowUpCategory.skin.rawValue, icon: "drop.fill", durationMinutes: 10),
            Routine(name: String(localized: "routine.eveningSkincare.name", defaultValue: "Evening Skincare"), description: String(localized: "routine.eveningSkincare.desc", defaultValue: "Double cleanse → Retinol → Night cream"), category: GlowUpCategory.skin.rawValue, icon: "moon.fill", durationMinutes: 10),
            Routine(name: String(localized: "routine.mewing.name", defaultValue: "Mewing Practice"), description: String(localized: "routine.mewing.desc", defaultValue: "Tongue on roof of mouth, teeth lightly together"), category: GlowUpCategory.faceStructure.rawValue, icon: "face.smiling.inverse", durationMinutes: 5),
            Routine(name: String(localized: "routine.gym.name", defaultValue: "Gym Session"), description: String(localized: "routine.gym.desc", defaultValue: "Push/Pull/Legs split"), category: GlowUpCategory.fitness.rawValue, icon: "dumbbell.fill", durationMinutes: 60),
            Routine(name: String(localized: "routine.posture.name", defaultValue: "Posture Check"), description: String(localized: "routine.posture.desc", defaultValue: "Chin tucks + shoulder blade squeezes"), category: GlowUpCategory.posture.rawValue, icon: "figure.stand", durationMinutes: 5),
            Routine(name: String(localized: "routine.hair.name", defaultValue: "Hair Care"), description: String(localized: "routine.hair.desc", defaultValue: "Style and maintain"), category: GlowUpCategory.hair.rawValue, icon: "comb.fill", durationMinutes: 10),
            Routine(name: String(localized: "routine.teeth.name", defaultValue: "Teeth Whitening"), description: String(localized: "routine.teeth.desc", defaultValue: "Whitening strips or oil pulling"), category: GlowUpCategory.teeth.rawValue, icon: "mouth.fill", durationMinutes: 15, isPremium: true),
            Routine(name: String(localized: "routine.coldShower.name", defaultValue: "Cold Shower"), description: String(localized: "routine.coldShower.desc", defaultValue: "2-minute cold exposure for skin & energy"), category: GlowUpCategory.skin.rawValue, icon: "snowflake", durationMinutes: 5, isPremium: true),
        ]
    }
}
