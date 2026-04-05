import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \Routine.sortOrder) private var routines: [Routine]
    @State private var viewModel = HomeViewModel()
    @State private var showDailyCheckIn = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    glowScoreSection
                    todayRoutinesSection
                    streakSection
                    quoteSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(Color.maxxBackground)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadToday(modelContext: modelContext)
            }
            .sheet(isPresented: $showDailyCheckIn) {
                DailyCheckInSheet(log: viewModel.todayLog)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.greeting)
                    .font(.subheadline)
                    .foregroundColor(.maxxTextSecondary)

                Text("Day \(profile?.daysSinceJoined ?? 0) of your glow-up")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            Spacer()

            Button {
                showDailyCheckIn = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.maxxGradient)
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Glow Score

    private var glowScoreSection: some View {
        VStack(spacing: 16) {
            GlowScoreRing(
                score: viewModel.calculateGlowScore(
                    profile: profile ?? UserProfile(),
                    routines: routines
                ),
                size: 160
            )

            Text("Today's Glow Score")
                .font(.subheadline)
                .foregroundColor(.maxxTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .maxxCard()
    }

    // MARK: - Today's Routines

    private var todayRoutinesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Routines")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                let scheduled = routines.filter(\.isScheduledToday)
                let completed = scheduled.filter(\.isCompletedToday).count
                Text("\(completed)/\(scheduled.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.maxxPrimary)
            }

            let todayRoutines = routines.filter { $0.isActive && $0.isScheduledToday }

            if todayRoutines.isEmpty {
                Text("No routines scheduled for today")
                    .font(.subheadline)
                    .foregroundColor(.maxxTextMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(todayRoutines) { routine in
                    RoutineRowView(routine: routine) {
                        toggleRoutine(routine)
                    }
                }
            }
        }
        .padding(20)
        .maxxCard()
    }

    // MARK: - Streak

    private var streakSection: some View {
        HStack(spacing: 20) {
            StreakBadgeView(
                count: profile?.currentStreak ?? 0,
                label: "Current",
                icon: "flame.fill",
                color: .maxxAccent
            )

            StreakBadgeView(
                count: profile?.longestStreak ?? 0,
                label: "Longest",
                icon: "trophy.fill",
                color: .maxxGold
            )

            StreakBadgeView(
                count: profile?.totalCheckIns ?? 0,
                label: "Total",
                icon: "checkmark.seal.fill",
                color: .maxxSuccess
            )
        }
    }

    // MARK: - Quote

    private var quoteSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.title3)
                .foregroundColor(.maxxPrimary)

            Text(viewModel.motivationalQuote)
                .font(.subheadline)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundColor(.maxxTextSecondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .maxxCard()
    }

    // MARK: - Actions

    private func toggleRoutine(_ routine: Routine) {
        if routine.isCompletedToday {
            routine.unmarkCompleted()
        } else {
            routine.markCompleted()
            profile?.updateStreak()
        }
        try? modelContext.save()
        HapticService.impact(.medium)
    }
}

// MARK: - Routine Row

struct RoutineRowView: View {
    let routine: Routine
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    onToggle()
                }
            } label: {
                Image(systemName: routine.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(routine.isCompletedToday ? .maxxSuccess : .maxxTextMuted)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(routine.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(routine.isCompletedToday ? .maxxTextSecondary : .white)
                    .strikethrough(routine.isCompletedToday)

                HStack(spacing: 8) {
                    if let category = routine.parsedCategory {
                        Text(category.rawValue)
                            .font(.caption2)
                            .foregroundColor(Color.categoryColor(for: category))
                    }

                    Text("\(routine.durationMinutes) min")
                        .font(.caption2)
                        .foregroundColor(.maxxTextMuted)
                }
            }

            Spacer()

            if routine.currentStreak > 1 {
                HStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                    Text("\(routine.currentStreak)")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
                .foregroundColor(.maxxAccent)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Daily Check-In Sheet

struct DailyCheckInSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var log: DailyLog?

    @State private var mood: Int = 3
    @State private var skinRating: Int = 3
    @State private var confidenceRating: Int = 3
    @State private var journalEntry: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    ratingSection(title: "Overall Mood", rating: $mood, icon: "face.smiling")
                    ratingSection(title: "Skin Today", rating: $skinRating, icon: "drop.fill")
                    ratingSection(title: "Confidence", rating: $confidenceRating, icon: "star.fill")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Journal (optional)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        TextEditor(text: $journalEntry)
                            .frame(minHeight: 100)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .background(Color.maxxSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundColor(.white)
                    }
                }
                .padding(20)
            }
            .background(Color.maxxBackground)
            .navigationTitle("Daily Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.maxxTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCheckIn()
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.maxxPrimary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .preferredColorScheme(.dark)
    }

    private func ratingSection(title: String, rating: Binding<Int>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.maxxPrimary)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { value in
                    Button {
                        rating.wrappedValue = value
                        HapticService.selection()
                    } label: {
                        Circle()
                            .fill(value <= rating.wrappedValue ? Color.maxxPrimary : Color.maxxSurfaceLight)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text("\(value)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
        }
    }

    private func saveCheckIn() {
        guard let log else { return }
        log.overallMood = mood
        log.skinRating = skinRating
        log.confidenceRating = confidenceRating
        log.journalEntry = journalEntry
        try? modelContext.save()
        HapticService.success()
    }
}
