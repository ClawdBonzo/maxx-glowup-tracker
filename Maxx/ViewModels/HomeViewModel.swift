import SwiftUI
import SwiftData

@Observable
@MainActor
final class HomeViewModel {
    var todayLog: DailyLog?
    var greeting: String = ""
    var motivationalQuote: String = ""

    private let quotes = [
        "Small daily improvements lead to massive results.",
        "Your glow-up is a marathon, not a sprint.",
        "Discipline is choosing between what you want now and what you want most.",
        "The best project you'll ever work on is you.",
        "Consistency beats intensity. Show up every day.",
        "You're one routine away from a completely different life.",
        "Invest in yourself. It pays the best interest.",
        "Rome wasn't built in a day, but they worked on it every day.",
        "The only competition is the person you were yesterday.",
        "A year from now, you'll wish you had started today.",
        "Champions don't show up to get everything they want; they show up to give everything they have.",
        "Progress, not perfection.",
        "Your face card should never decline.",
        "Mewing today, model tomorrow.",
        "Stay hard. Stay consistent. Stay glowing.",
    ]

    func loadToday(modelContext: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)
        let descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.date == today }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            todayLog = existing
        } else {
            let newLog = DailyLog()
            modelContext.insert(newLog)
            try? modelContext.save()
            todayLog = newLog
        }

        updateGreeting()
        motivationalQuote = quotes.randomElement() ?? quotes[0]
    }

    func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12:
            greeting = "Good Morning"
        case 12..<17:
            greeting = "Good Afternoon"
        case 17..<22:
            greeting = "Good Evening"
        default:
            greeting = "Night Owl Mode"
        }
    }

    func todayCompletionPercentage(routines: [Routine]) -> Double {
        let scheduled = routines.filter(\.isScheduledToday)
        guard !scheduled.isEmpty else { return 0 }
        let completed = scheduled.filter(\.isCompletedToday).count
        return Double(completed) / Double(scheduled.count)
    }

    func calculateGlowScore(profile: UserProfile, routines: [Routine]) -> Double {
        let completionRate = todayCompletionPercentage(routines: routines)
        let streakBonus = min(Double(profile.currentStreak) * 2, 20)
        let moodScore: Double
        if let log = todayLog {
            moodScore = log.averageRating / 5.0 * 30
        } else {
            moodScore = 0
        }
        let score = (completionRate * 50) + streakBonus + moodScore
        return min(score, 100)
    }
}
