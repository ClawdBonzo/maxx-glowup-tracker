import SwiftUI
import SwiftData

struct GamificationTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subManager
    @State private var selectedTab: GamTab = .quests
    @State private var showShare = false
    @State private var showPremiumGate = false
    @State private var premiumGateFeature: PremiumGateView.ProFeature = .quests

    /// Shared across all tabs — created in ContentView
    var gamificationVM: GamificationViewModel?

    enum GamTab {
        case quests, badges, level
    }

    var body: some View {
        ZStack {
            NeonScreenBackground(particleCount: 20)

            VStack(spacing: 0) {
                // Header
                if let vm = gamificationVM {
                    let (level, progress) = vm.currentLevelInfo()
                    headerView(vm: vm, level: level, progress: progress)
                }

                // Tab Picker
                tabPicker

                // Content
                if let vm = gamificationVM {
                    TabView(selection: $selectedTab) {
                        Group {
                            if subManager.isPremium {
                                QuestsTabContentView(viewModel: vm)
                            } else {
                                proLockedTab(feature: .quests)
                            }
                        }
                        .tag(GamTab.quests)

                        Group {
                            if subManager.isPremium {
                                BadgesTabContentView(viewModel: vm)
                            } else {
                                proLockedTab(feature: .badges)
                            }
                        }
                        .tag(GamTab.badges)

                        let (level, progress) = vm.currentLevelInfo()
                        LevelTabContentView(
                            level: level,
                            progress: progress,
                            totalXP: vm.gamificationState.totalXP,
                            streak: vm.gamificationState.currentStreak,
                            onShare: {
                                if subManager.isPremium {
                                    showShare = true
                                } else {
                                    premiumGateFeature = .shareCard
                                    showPremiumGate = true
                                }
                            }
                        )
                        .tag(GamTab.level)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }

            // Celebration overlays are now in ContentView (shared across all tabs)
        }
        .sheet(isPresented: $showShare) {
            if let vm = gamificationVM {
                let (level, _) = vm.currentLevelInfo()
                ShareGlowUpView(
                    title: "Level \(level.displayName)",
                    emoji: level.emoji,
                    subtitle: "I'm leveling up my glow-up 🔥",
                    level: level.displayName,
                    streak: vm.gamificationState.currentStreak
                )
            }
        }
        .sheet(isPresented: $showPremiumGate) {
            PremiumGateView(feature: premiumGateFeature)
        }
        .onAppear {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-screenshotMode") {
                selectedTab = .level
            }
            #endif
        }
    }

    // MARK: - Pro Locked Tab

    private func proLockedTab(feature: PremiumGateView.ProFeature) -> some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(feature.accentColor.opacity(0.10))
                    .frame(width: 80, height: 80)

                Image(systemName: "lock.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [feature.accentColor, feature.accentColor.opacity(0.5)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: 8) {
                Text(feature.title)
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)

                Text(feature.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.maxxTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                premiumGateFeature = feature
                showPremiumGate = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                    Text("Unlock with Pro")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.maxxPrimary, Color(hex: "6B0FD4")],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .maxxPrimary.opacity(0.4), radius: 12, y: 4)
            }

            Spacer()
        }
    }

    // MARK: - Header

    private func headerView(vm: GamificationViewModel, level: JawlineLevel, progress: Double) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your Glow-Up")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.maxxSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    HStack(spacing: 8) {
                        Text(level.emoji)
                            .font(.headline)
                            .neonGlow(color: .maxxPrimary, radius: 8)
                        Text(level.displayName)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.maxxCyan, .maxxPrimary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(vm.gamificationState.totalXP)")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.maxxCyan, .maxxGold],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .neonGlow(color: .maxxCyan, radius: 10)

                    Text("XP")
                        .font(.caption2)
                        .fontWeight(.black)
                        .foregroundColor(.maxxTextMuted)

                    // Streak
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .neonGlow(color: .maxxAccent, radius: 5)
                        Text("\(vm.gamificationState.currentStreak) day streak")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.maxxAccent, .maxxGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
            }

            // XP progress bar (neon)
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
                        .blur(radius: 8)
                        .opacity(0.6)

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
            }
            .frame(height: 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.maxxSurface.opacity(0.8))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.maxxPrimary.opacity(0.5), .maxxCyan.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                ),
            alignment: .bottom
        )
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        HStack {
            ForEach([GamTab.quests, GamTab.badges, GamTab.level], id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = tab
                    }
                    HapticService.selection()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcon(tab))
                            .font(.headline)
                            .neonGlow(
                                color: selectedTab == tab ? tabColor(tab) : .clear,
                                radius: 6,
                                intensity: 0.7
                            )

                        Text(tabName(tab))
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(
                        selectedTab == tab
                            ? AnyShapeStyle(LinearGradient(
                                colors: [tabColor(tab), tabColor(tab).opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            : AnyShapeStyle(Color.maxxTextMuted)
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundStyle(
                                selectedTab == tab
                                    ? AnyShapeStyle(LinearGradient(
                                        colors: [tabColor(tab), tabColor(tab).opacity(0.5)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    : AnyShapeStyle(Color.clear)
                            )
                            .shadow(color: tabColor(tab).opacity(selectedTab == tab ? 0.8 : 0), radius: 6),
                        alignment: .bottom
                    )
                }
            }
        }
        .background(Color.maxxSurface.opacity(0.9))
    }

    private func tabIcon(_ tab: GamTab) -> String {
        switch tab {
        case .quests: "checklist"
        case .badges: "star.fill"
        case .level:  "flame.fill"
        }
    }

    private func tabName(_ tab: GamTab) -> String {
        switch tab {
        case .quests: "Quests"
        case .badges: "Badges"
        case .level:  "Level"
        }
    }

    private func tabColor(_ tab: GamTab) -> Color {
        switch tab {
        case .quests: .maxxCyan
        case .badges: .maxxGold
        case .level:  .maxxPrimary
        }
    }
}

// MARK: - Quests Tab

struct QuestsTabContentView: View {
    let viewModel: GamificationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                let completed = viewModel.getCompletedDailyQuests()
                let active = viewModel.getActiveDailyQuests()

                if !active.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Active Quests")
                                .font(.headline)
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(active.count) remaining")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.maxxTextMuted)
                        }
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
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Completed")
                                .font(.headline)
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(completed.count) done ✓")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.maxxCyan, .maxxGold],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        .padding(.horizontal, 20)

                        ForEach(completed, id: \.id) { quest in
                            QuestCardView(quest: quest, isCompleted: true, onComplete: {})
                        }
                    }
                }

                if active.isEmpty && completed.isEmpty {
                    VStack(spacing: 16) {
                        Text("🎯")
                            .font(.system(size: 52))
                            .neonGlow(color: .maxxPrimary, radius: 12)
                        Text("No quests yet")
                            .font(.headline)
                            .foregroundColor(.maxxTextMuted)
                        Text("Complete routines and check-ins to unlock quests")
                            .font(.caption)
                            .foregroundColor(.maxxTextMuted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                }
            }
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Badges Tab

struct BadgesTabContentView: View {
    let viewModel: GamificationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                let unlocked = viewModel.getUnlockedBadges()
                let locked = viewModel.getLockedBadges()

                if !unlocked.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Unlocked")
                                .font(.headline)
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            Text("\(unlocked.count)")
                                .font(.caption)
                                .fontWeight(.black)
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    LinearGradient(
                                        colors: [.maxxGold, Color(hex: "FF8C00")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .neonGlow(color: .maxxGold, radius: 5)
                        }
                        .padding(.horizontal, 20)

                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(unlocked, id: \.id) { badge in
                                BadgeCardView(badge: badge, showUnlocked: true)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                if !locked.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Locked")
                                .font(.headline)
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            Text("\(locked.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.maxxTextMuted)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.maxxSurfaceLight)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 20)

                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(locked, id: \.id) { badge in
                                BadgeCardView(badge: badge, showUnlocked: false)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Level Tab

struct LevelTabContentView: View {
    let level: JawlineLevel
    let progress: Double
    let totalXP: Int
    var streak: Int = 0
    var onShare: (() -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Level ring display
                GlowScoreRingView(level: level, progress: progress, totalXP: totalXP)
                    .padding(.top, 12)

                // Share glow-up button
                Button {
                    onShare?()
                    HapticService.impact(.medium)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                        Text("Share My Glow-Up")
                            .font(.headline)
                            .fontWeight(.black)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.maxxPrimary, .maxxCyan, .maxxGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .maxxPrimary.opacity(0.5), radius: 14)
                    .shadow(color: .maxxCyan.opacity(0.3), radius: 24)
                }
                .padding(.horizontal, 24)

                // Level roadmap
                VStack(spacing: 0) {
                    Text("Level Roadmap")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 14)

                    ForEach(Array(JawlineLevel.allCases.enumerated()), id: \.element) { index, lv in
                        let isReached = lv.xpRequired <= totalXP
                        let isCurrent = lv == level

                        HStack(spacing: 16) {
                            // Level indicator
                            ZStack {
                                Circle()
                                    .fill(
                                        isReached
                                            ? AnyShapeStyle(LinearGradient(
                                                colors: [.maxxPrimary, .maxxCyan],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ))
                                            : AnyShapeStyle(Color.maxxSurfaceLight)
                                    )
                                    .frame(width: 44, height: 44)
                                    .neonGlow(
                                        color: isCurrent ? .maxxCyan : .clear,
                                        radius: 10,
                                        intensity: isCurrent ? 0.9 : 0
                                    )

                                Text(lv.emoji)
                                    .font(.headline)
                                    .opacity(isReached ? 1 : 0.4)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(lv.displayName)
                                        .font(.body)
                                        .fontWeight(.bold)
                                        .foregroundColor(isReached ? .white : .maxxTextMuted)

                                    if isCurrent {
                                        Text("YOU ARE HERE")
                                            .font(.system(size: 9, weight: .black))
                                            .tracking(1)
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 7)
                                            .padding(.vertical, 3)
                                            .background(
                                                LinearGradient(
                                                    colors: [.maxxCyan, .maxxGold],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .clipShape(Capsule())
                                            .neonGlow(color: .maxxCyan, radius: 5)
                                    }
                                }

                                Text("\(lv.xpRequired) XP required")
                                    .font(.caption)
                                    .foregroundColor(.maxxTextMuted)
                            }

                            Spacer()

                            if isReached {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.maxxPrimary, .maxxCyan],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .neonGlow(color: .maxxCyan, radius: 5)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            isCurrent
                                ? Color.maxxPrimary.opacity(0.08)
                                : Color.clear
                        )
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.white.opacity(0.05)),
                            alignment: .bottom
                        )
                    }
                }
                .neonCard(cornerRadius: 20, glowColor: .maxxPrimary)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    GamificationTabView(gamificationVM: nil)
        .modelContainer(for: [Quest.self, Badge.self, GamificationState.self])
}
