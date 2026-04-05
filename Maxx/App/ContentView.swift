import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var hasCompletedOnboarding = false
    @State private var selectedTab: AppTab = .home
    @State private var showSplash = true

    private var profile: UserProfile? { profiles.first }

    enum AppTab: String, CaseIterable {
        case home = "Home"
        case progress = "Progress"
        case routines = "Routines"
        case analytics = "Analytics"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .home: "house.fill"
            case .progress: "camera.fill"
            case .routines: "checkmark.circle.fill"
            case .analytics: "chart.line.uptrend.xyaxis"
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
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.maxxPrimary, .maxxAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("MAXX")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .tracking(6)
                .foregroundColor(.white)
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

                AnalyticsDashboardView()
                    .tag(AppTab.analytics)

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
                        Image(systemName: tab.icon)
                            .font(.system(size: 20))
                            .symbolEffect(.bounce, value: selectedTab == tab)

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
    }
}
