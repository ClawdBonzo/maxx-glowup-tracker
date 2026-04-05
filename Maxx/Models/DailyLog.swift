import Foundation
import SwiftData

@Model
final class DailyLog {
    var id: UUID
    var date: Date
    var completedRoutineIDs: [UUID]
    var overallMood: Int
    var skinRating: Int
    var hairRating: Int
    var fitnessRating: Int
    var confidenceRating: Int
    var journalEntry: String
    var glowScore: Double

    init(date: Date = .now) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.completedRoutineIDs = []
        self.overallMood = 3
        self.skinRating = 3
        self.hairRating = 3
        self.fitnessRating = 3
        self.confidenceRating = 3
        self.journalEntry = ""
        self.glowScore = 0
    }

    var completionPercentage: Double {
        guard !completedRoutineIDs.isEmpty else { return 0 }
        return Double(completedRoutineIDs.count)
    }

    var averageRating: Double {
        let ratings = [skinRating, hairRating, fitnessRating, confidenceRating, overallMood]
        return Double(ratings.reduce(0, +)) / Double(ratings.count)
    }

    func calculateGlowScore(totalRoutines: Int) -> Double {
        let routineScore: Double
        if totalRoutines > 0 {
            routineScore = (Double(completedRoutineIDs.count) / Double(totalRoutines)) * 40
        } else {
            routineScore = 0
        }
        let ratingScore = averageRating / 5.0 * 40
        let journalBonus: Double = journalEntry.isEmpty ? 0 : 20
        return min(routineScore + ratingScore + journalBonus, 100)
    }
}
