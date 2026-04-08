import SwiftUI
import SwiftData
import RevenueCat

@main
struct MaxxGlowUpApp: App {
    @State private var subscriptionManager = SubscriptionManager.shared

    init() {
        // Configure RevenueCat SDK
        Purchases.logLevel = .debug
        // TODO: Replace with LIVE key (starts with "live_") before submitting to App Store
        Purchases.configure(withAPIKey: "appl_TlXDHfbMGnSrHUfrInSbSaENgvS")

        // Start subscription manager (sets delegate, fetches offerings + entitlements)
        SubscriptionManager.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(subscriptionManager)
        }
        .modelContainer(for: [
            UserProfile.self,
            ProgressPhoto.self,
            DailyLog.self,
            Routine.self,
            GamificationState.self,
            Quest.self,
            Badge.self,
        ])
    }
}
