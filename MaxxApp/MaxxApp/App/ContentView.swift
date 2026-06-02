import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subManager
    @Query private var profiles: [UserProfile]
    @State private var hasCompletedOnboarding = false
    @State private var selectedTab: AppTab = .home
    @State private var showSplash = true
    @State private var gamificationVM: GamificationViewModel?
    #if DEBUG
    @State private var showAnalyticsScreenshot = false
    #endif

    private var profile: UserProfile? { profiles.first }

    enum AppTab: String, CaseIterable {
        case home = "Home"
        case progress = "Progress"
        case routines = "Routines"
        case gamification = "Glow-Up"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .home: "TabDashboard"
            case .progress: "TabPhotoJournal"
            case .routines: "TabRoutines"
            case .gamification: "TabProgressCharts"
            case .settings: "TabDailyLog"
            }
        }

        var sfIcon: String {
            switch self {
            case .home: "house.fill"
            case .progress: "camera.fill"
            case .routines: "checkmark.circle.fill"
            case .gamification: "flame.fill"
            case .settings: "gearshape.fill"
            }
        }
    }

    private var isPaywallTest: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("-paywallTest")
        #else
        return false
        #endif
    }

    var body: some View {
        ZStack {
            Color.maxxBackground.ignoresSafeArea()

            if showSplash {
                splashScreen
            } else if isPaywallTest {
                PaywallView(viewModel: OnboardingViewModel()) {}
            } else if hasCompletedOnboarding {
                mainTabView
            } else {
                OnboardingContainerView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .preferredColorScheme(.dark)
        #if DEBUG
        .fullScreenCover(isPresented: $showAnalyticsScreenshot) {
            AnalyticsDashboardView()
        }
        #endif
        .onAppear {
            checkOnboardingStatus()

            // Create the shared GamificationViewModel once for all tabs
            if gamificationVM == nil {
                gamificationVM = GamificationViewModel(modelContext: modelContext)
                gamificationVM?.createDailyQuests()
            }

            #if DEBUG
            if DemoSeed.isScreenshotMode {
                applyScreenshotTab()
                showSplash = false
                return
            }
            #endif

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }

    #if DEBUG
    private func applyScreenshotTab() {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-screenshotTab"), i + 1 < args.count else { return }
        switch args[i + 1] {
        case "home":         selectedTab = .home
        case "progress":     selectedTab = .progress
        case "routines":     selectedTab = .routines
        case "gamification": selectedTab = .gamification
        case "settings":     selectedTab = .settings
        case "analytics":    showAnalyticsScreenshot = true
        default: break
        }
    }
    #endif

    // MARK: - Splash Screen

    private var splashScreen: some View {
        Image("SplashDark")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
            .transition(.opacity)
    }

    // MARK: - Main Tab View

    private var mainTabView: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(gamificationVM: gamificationVM)
                    .tag(AppTab.home)

                ProgressGalleryView(gamificationVM: gamificationVM)
                    .tag(AppTab.progress)

                RoutinesListView(gamificationVM: gamificationVM)
                    .tag(AppTab.routines)

                GamificationTabView(gamificationVM: gamificationVM)
                    .tag(AppTab.gamification)

                SettingsView()
                    .tag(AppTab.settings)
            }
            .tabViewStyle(.automatic)

            // Custom Tab Bar
            customTabBar

            // Global celebration overlays
            if let vm = gamificationVM {
                if vm.showLevelUpAnimation {
                    let (level, _) = vm.currentLevelInfo()
                    LevelUpAnimationView(level: level)
                        .transition(.opacity)
                        .zIndex(100)
                }

                if vm.showBadgeUnlockAnimation, let badge = vm.selectedBadge {
                    BadgeUnlockAnimationView(badge: badge)
                        .transition(.opacity)
                        .zIndex(100)
                }
            }
        }
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = tab
                        HapticService.selection()
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(tab.icon)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)

                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(selectedTab == tab ? .maxxPrimary : .maxxTextMuted)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 0.5)
        }
    }

    // MARK: - Helpers

    private func checkOnboardingStatus() {
        hasCompletedOnboarding = profile?.hasCompletedOnboarding ?? false

        // Break a stale streak if a day was missed since the last activity.
        if let profile {
            let before = profile.currentStreak
            profile.refreshStreak()
            if profile.currentStreak != before { try? modelContext.save() }
        }

        // Sync premium state from RevenueCat → SwiftData
        if let profile, subManager.isPremium, !profile.isPremium {
            profile.isPremium = true
            try? modelContext.save()
        }
    }
}
