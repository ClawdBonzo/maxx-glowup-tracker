import SwiftUI
import SwiftData

struct GamificationTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gamificationVM: GamificationViewModel?
    @State private var selectedTab: GamTab = .quests

    enum GamTab {
        case quests
        case badges
        case level
    }

    var body: some View {
        ZStack {
            Color.maxxBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with level
                if let vm = gamificationVM {
                    let (level, progress) = vm.currentLevelInfo()
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Glow-Up")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            HStack(spacing: 8) {
                                Text(level.emoji)
                                    .font(.headline)
                                Text(level.displayName)
                                    .font(.caption)
                                    .foregroundColor(.maxxTextMuted)
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(vm.gamificationState.totalXP)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "00CEC9"))
                            Text("XP")
                                .font(.caption2)
                                .foregroundColor(.maxxTextMuted)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }

                // Tab Picker
                HStack {
                    ForEach([GamTab.quests, GamTab.badges, GamTab.level], id: \.self) { tab in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTab = tab
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Image(systemName: tabIcon(tab))
                                    .font(.headline)
                                Text(tabName(tab))
                                    .font(.caption)
                            }
                            .foregroundColor(selectedTab == tab ? Color(hex: "00CEC9") : .maxxTextMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                    }
                }
                .background(Color.maxxSurface)

                // Content
                if let vm = gamificationVM {
                    TabView(selection: $selectedTab) {
                        QuestsTabContentView(viewModel: vm)
                            .tag(GamTab.quests)

                        BadgesTabContentView(viewModel: vm)
                            .tag(GamTab.badges)

                        let (level, progress) = vm.currentLevelInfo()
                        LevelTabContentView(level: level, progress: progress, totalXP: vm.gamificationState.totalXP)
                            .tag(GamTab.level)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }

            // Animations Overlays
            if let vm = gamificationVM {
                if vm.showLevelUpAnimation {
                    let (level, _) = vm.currentLevelInfo()
                    LevelUpAnimationView(level: level)
                        .transition(.opacity)
                }

                if vm.showBadgeUnlockAnimation, let badge = vm.selectedBadge {
                    BadgeUnlockAnimationView(badge: badge)
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            if gamificationVM == nil {
                gamificationVM = GamificationViewModel(modelContext: modelContext)
                gamificationVM?.createDailyQuests()
            }
        }
    }

    private func tabIcon(_ tab: GamTab) -> String {
        switch tab {
        case .quests: "checklist"
        case .badges: "star.fill"
        case .level: "flame.fill"
        }
    }

    private func tabName(_ tab: GamTab) -> String {
        switch tab {
        case .quests: "Quests"
        case .badges: "Badges"
        case .level: "Level"
        }
    }
}

// MARK: - Tab Contents

struct QuestsTabContentView: View {
    let viewModel: GamificationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                let completed = viewModel.getCompletedDailyQuests()
                let active = viewModel.getActiveDailyQuests()

                if !active.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Active Quests")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        ForEach(active, id: \.id) { quest in
                            QuestCardView(
                                quest: quest,
                                isCompleted: false,
                                onComplete: { viewModel.completeQuest(quest) }
                            )
                        }
                    }
                }

                if !completed.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Completed")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        ForEach(completed, id: \.id) { quest in
                            QuestCardView(
                                quest: quest,
                                isCompleted: true,
                                onComplete: {}
                            )
                        }
                    }
                }

                if active.isEmpty && completed.isEmpty {
                    VStack(spacing: 12) {
                        Text("🎯")
                            .font(.system(size: 48))
                        Text("No quests yet")
                            .foregroundColor(.maxxTextMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
            .padding(.vertical, 16)
        }
    }
}

struct BadgesTabContentView: View {
    let viewModel: GamificationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                let unlocked = viewModel.getUnlockedBadges()
                let locked = viewModel.getLockedBadges()

                if !unlocked.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Unlocked (\(unlocked.count))")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(unlocked, id: \.id) { badge in
                                BadgeCardView(badge: badge, showUnlocked: true)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                if !locked.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Locked (\(locked.count))")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(locked, id: \.id) { badge in
                                BadgeCardView(badge: badge, showUnlocked: false)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.vertical, 16)
        }
    }
}

struct LevelTabContentView: View {
    let level: JawlineLevel
    let progress: Double
    let totalXP: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                GlowScoreRingView(level: level, progress: progress, totalXP: totalXP)

                VStack(spacing: 12) {
                    ForEach(JawlineLevel.allCases, id: \.self) { lv in
                        HStack {
                            Text(lv.emoji)
                                .font(.headline)
                            Text(lv.displayName)
                                .font(.body)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(lv.xpRequired) XP")
                                .font(.caption)
                                .foregroundColor(.maxxTextMuted)
                        }
                        .padding(.horizontal, 20)
                        .opacity(lv.xpRequired <= totalXP ? 1 : 0.5)
                    }
                }
            }
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    GamificationTabView()
        .modelContainer(for: [Quest.self, Badge.self, GamificationState.self])
}
