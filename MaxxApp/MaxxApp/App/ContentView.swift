import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subManager
    @Query private var profiles: [UserProfile]
    @State private var hasCompletedOnboarding = false
    @State private var selectedTab: AppTab = .home
    @State private var showSplash = true

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

    var body: some View {
        ZStack {
            Color.maxxBackground.ignoresSafeArea()

            if showSplash {
                splashScreen
            } else if hasCompletedOnboarding {
                mainTabView
            } else {
                OnboardingContainerView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            checkOnboardingStatus()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }

    // MARK: - Splash Screen

    private var splashScreen: some View {
        ZStack {
            Image("SplashDark")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image("MaxxLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: .maxxPrimary.opacity(0.5), radius: 20)

                Text("MAXX")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .tracking(6)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .maxxSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .transition(.opacity)
    }

    // MARK: - Main Tab View

    private var mainTabView: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(AppTab.home)

                ProgressGalleryView()
                    .tag(AppTab.progress)

                RoutinesListView()
                    .tag(AppTab.routines)

                GamificationTabView()
                    .tag(AppTab.gamification)

                SettingsView()
                    .tag(AppTab.settings)
            }
            .tabViewStyle(.automatic)

            // Custom Tab Bar
            customTabBar
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

        // Sync premium state from RevenueCat → SwiftData
        if let profile, subManager.isPremium, !profile.isPremium {
            profile.isPremium = true
            try? modelContext.save()
        }
    }
}
