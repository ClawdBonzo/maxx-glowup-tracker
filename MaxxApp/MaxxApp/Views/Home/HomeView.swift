import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \Routine.sortOrder) private var routines: [Routine]
    @Environment(SubscriptionManager.self) private var subManager
    @State private var viewModel = HomeViewModel()
    @State private var showDailyCheckIn = false
    @State private var showAnalytics = false
    @State private var showAnalyticsGate = false

    /// Shared across all tabs — created in ContentView
    var gamificationVM: GamificationViewModel?

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ZStack {
                // Neon ambient background with particles
                NeonScreenBackground(particleCount: 18)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        headerSection
                        if let vm = gamificationVM {
                            gamificationProgressSection(viewModel: vm)
                        }
                        glowScoreSection
                        todayRoutinesSection
                        streakSection
                        quoteSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadToday(modelContext: modelContext)
            }
            .sheet(isPresented: $showDailyCheckIn) {
                DailyCheckInSheet(log: viewModel.todayLog, gamificationVM: gamificationVM)
            }
            .sheet(isPresented: $showAnalytics) {
                AnalyticsDashboardView()
            }
            .sheet(isPresented: $showAnalyticsGate) {
                PremiumGateView(feature: .analytics)
            }
        }
    }

    // MARK: - Gamification Progress

    private func gamificationProgressSection(viewModel: GamificationViewModel) -> some View {
        let (level, progress) = viewModel.currentLevelInfo()
        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.emoji)
                        .font(.title)
                        .neonGlow(color: .maxxPrimary, radius: 10)
                    Text(level.displayName)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.maxxCyan, .maxxPrimary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .frame(width: 60)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(viewModel.gamificationState.totalXP) XP")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.maxxCyan)
                    }

                    // Neon XP progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.maxxSurfaceLight)
                                .frame(height: 8)

                            // Glow bloom
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.maxxPrimary, .maxxCyan, .maxxGold],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * max(progress, 0.03), height: 8)
                                .blur(radius: 6)
                                .opacity(0.7)

                            // Sharp bar
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.maxxPrimary, .maxxCyan, .maxxGold],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * max(progress, 0.03), height: 8)
                        }
                        .animation(.spring(response: 0.6), value: progress)
                    }
                    .frame(height: 8)
                }

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .neonGlow(color: .maxxAccent, radius: 6)
                        Text("\(viewModel.gamificationState.currentStreak)")
                            .font(.subheadline)
                            .fontWeight(.black)
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.maxxAccent, .maxxGold],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    Text("streak")
                        .font(.caption2)
                        .foregroundColor(.maxxTextMuted)
                }
                .frame(width: 60)
            }
        }
        .padding(16)
        .neonCard(cornerRadius: 20, glowColor: .maxxPrimary)
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
                    .fontWeight(.black)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color.maxxSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            Spacer()

            HStack(spacing: 12) {
                Button {
                    if subManager.isPremium { showAnalytics = true }
                    else { showAnalyticsGate = true }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.maxxCyan.opacity(0.15))
                            .frame(width: 42, height: 42)
                            .neonGlow(color: .maxxCyan, radius: 8)

                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.maxxCyan, .maxxPrimary],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                }
                .accessibilityLabel(Text("Analytics"))

                Button {
                    showDailyCheckIn = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.maxxPrimary.opacity(0.15))
                            .frame(width: 42, height: 42)
                            .neonGlow(color: .maxxPrimary, radius: 8)

                        Image(systemName: "plus")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.maxxPrimary, .maxxCyan],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                }

                Image("MaxxLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .neonGlow(color: .maxxPrimary, radius: 6)
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
                .fontWeight(.semibold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.maxxCyan, .maxxPrimary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .neonCard(cornerRadius: 24, glowColor: .maxxCyan)
    }

    // MARK: - Today's Routines

    private var todayRoutinesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Routines")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Spacer()

                let scheduled = routines.filter(\.isScheduledToday)
                let completed = scheduled.filter(\.isCompletedToday).count
                Text("\(completed)/\(scheduled.count)")
                    .font(.subheadline)
                    .fontWeight(.black)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.maxxPrimary, .maxxCyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
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
        .neonCard(cornerRadius: 20, glowColor: .maxxPrimary)
    }

    // MARK: - Streak

    private var streakSection: some View {
        HStack(spacing: 14) {
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
                color: .maxxCyan
            )
        }
    }

    // MARK: - Quote

    private var quoteSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.title3)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.maxxPrimary, .maxxCyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .neonGlow(color: .maxxPrimary, radius: 6)

            Text(viewModel.motivationalQuote)
                .font(.subheadline)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundColor(.maxxTextSecondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .neonCard(cornerRadius: 20, glowColor: .maxxGold)
    }

    // MARK: - Actions

    private func toggleRoutine(_ routine: Routine) {
        if routine.isCompletedToday {
            routine.unmarkCompleted()
        } else {
            routine.markCompleted()
            profile?.updateStreak()
            let xpReward = 25 + (routine.durationMinutes / 5)
            gamificationVM?.addXP(xpReward, reason: "Routine: \(routine.name)")
        }
        try? modelContext.save()
        HapticService.impact(.medium)
    }
}

// MARK: - Routine Row

struct RoutineRowView: View {
    let routine: Routine
    let onToggle: () -> Void
    @State private var didComplete = false

    var body: some View {
        HStack(spacing: 14) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    onToggle()
                    if !routine.isCompletedToday { didComplete = true }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            routine.isCompletedToday
                                ? AnyShapeStyle(LinearGradient(
                                    colors: [.maxxPrimary, .maxxCyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                : AnyShapeStyle(Color.maxxSurfaceLight)
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: routine.isCompletedToday ? "checkmark" : "circle")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .neonGlow(
                    color: routine.isCompletedToday ? .maxxCyan : .clear,
                    radius: 8
                )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(routine.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(routine.isCompletedToday ? .maxxTextSecondary : .white)
                    .strikethrough(routine.isCompletedToday)

                HStack(spacing: 8) {
                    if let category = routine.parsedCategory {
                        Text(category.displayName)
                            .font(.caption2)
                            .fontWeight(.semibold)
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
                        .neonGlow(color: .maxxAccent, radius: 4)
                    Text("\(routine.currentStreak)")
                        .font(.caption2)
                        .fontWeight(.black)
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [.maxxAccent, .maxxGold],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
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
    var gamificationVM: GamificationViewModel?

    @State private var mood: Int = 3
    @State private var skinRating: Int = 3
    @State private var confidenceRating: Int = 3
    @State private var journalEntry: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                NeonScreenBackground(particleCount: 10)
                ScrollView {
                    VStack(spacing: 28) {
                        ratingSection(title: "Overall Mood", rating: $mood, icon: "face.smiling", color: .maxxGold)
                        ratingSection(title: "Skin Today", rating: $skinRating, icon: "drop.fill", color: .maxxCyan)
                        ratingSection(title: "Confidence", rating: $confidenceRating, icon: "star.fill", color: .maxxPrimary)

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
            }
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
                    .fontWeight(.black)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.maxxPrimary, .maxxCyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
            }
        }
        .presentationDetents([.medium, .large])
        .preferredColorScheme(.dark)
    }

    private func ratingSection(title: LocalizedStringKey, rating: Binding<Int>, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .neonGlow(color: color, radius: 6)
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
                        ZStack {
                            Circle()
                                .fill(
                                    value <= rating.wrappedValue
                                        ? AnyShapeStyle(LinearGradient(
                                            colors: [color, color.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        : AnyShapeStyle(Color.maxxSurfaceLight)
                                )
                                .frame(width: 44, height: 44)
                                .neonGlow(
                                    color: value <= rating.wrappedValue ? color : .clear,
                                    radius: 6,
                                    intensity: value <= rating.wrappedValue ? 0.8 : 0
                                )

                            Text("\(value)")
                                .font(.subheadline)
                                .fontWeight(.black)
                                .foregroundColor(.white)
                        }
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

        let baseXP = 50
        let bonusXP = (mood + skinRating + confidenceRating) / 3 - 3
        gamificationVM?.addXP(baseXP + max(0, bonusXP * 5), reason: "Daily check-in")
        HapticService.success()
    }
}
