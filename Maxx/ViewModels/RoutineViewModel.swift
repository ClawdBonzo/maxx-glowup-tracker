import SwiftUI
import SwiftData

@Observable
@MainActor
final class RoutineViewModel {
    var showAddRoutine = false
    var editingRoutine: Routine?
    var selectedCategory: GlowUpCategory?
    var newRoutineName = ""
    var newRoutineDescription = ""
    var newRoutineCategory: GlowUpCategory = .skin
    var newRoutineDuration = 10
    var newRoutineDays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]

    func toggleRoutineCompletion(_ routine: Routine, modelContext: ModelContext) {
        if routine.isCompletedToday {
            routine.unmarkCompleted()
        } else {
            routine.markCompleted()
        }
        try? modelContext.save()
        HapticService.impact(.medium)
    }

    func addRoutine(modelContext: ModelContext) {
        guard !newRoutineName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let routine = Routine(
            name: newRoutineName.trimmingCharacters(in: .whitespaces),
            description: newRoutineDescription.trimmingCharacters(in: .whitespaces),
            category: newRoutineCategory.rawValue,
            durationMinutes: newRoutineDuration,
            daysOfWeek: Array(newRoutineDays).sorted()
        )

        modelContext.insert(routine)
        try? modelContext.save()

        resetForm()
        HapticService.success()
    }

    func deleteRoutine(_ routine: Routine, modelContext: ModelContext) {
        modelContext.delete(routine)
        try? modelContext.save()
        HapticService.impact(.medium)
    }

    func toggleRoutineActive(_ routine: Routine, modelContext: ModelContext) {
        routine.isActive.toggle()
        try? modelContext.save()
    }

    func routinesForCategory(_ category: GlowUpCategory?, allRoutines: [Routine]) -> [Routine] {
        guard let category else { return allRoutines.filter(\.isActive) }
        return allRoutines.filter { $0.isActive && $0.category == category.rawValue }
    }

    func todaysRoutines(_ allRoutines: [Routine]) -> [Routine] {
        allRoutines.filter { $0.isActive && $0.isScheduledToday }
    }

    func completedTodayCount(_ routines: [Routine]) -> Int {
        todaysRoutines(routines).filter(\.isCompletedToday).count
    }

    func totalTodayCount(_ routines: [Routine]) -> Int {
        todaysRoutines(routines).count
    }

    private func resetForm() {
        newRoutineName = ""
        newRoutineDescription = ""
        newRoutineCategory = .skin
        newRoutineDuration = 10
        newRoutineDays = [1, 2, 3, 4, 5, 6, 7]
    }

    static let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    static let dayValues = [1, 2, 3, 4, 5, 6, 7]
}
