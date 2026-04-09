import SwiftUI
import SwiftData
import RevenueCat

@main
struct MaxxGlowUpApp: App {
    @State private var subscriptionManager = SubscriptionManager.shared

    init() {
        // Configure RevenueCat SDK.
        // Key "appl_TlXDHfbMGnSrHUfrInSbSaENgvS" is the PRODUCTION public SDK key
        // for the "Maxx: Glow-Up Tracker" app (verified Apr 7 2026 in RC dashboard).
        // Apple public SDK keys start with "appl_" — this is correct and ready for App Store.
        #if DEBUG
        Purchases.logLevel = .info
        #else
        Purchases.logLevel = .error
        #endif
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
