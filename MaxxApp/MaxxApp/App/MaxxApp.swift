import SwiftUI
import SwiftData
import RevenueCat

@main
struct MaxxGlowUpApp: App {
    @State private var subscriptionManager = SubscriptionManager.shared

    let modelContainer: ModelContainer

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

        // Create SwiftData model container with migration-safe fallback.
        // If the store is corrupted (e.g. schema change from dev builds),
        // delete and recreate rather than crashing on launch.
        let schema = Schema([
            UserProfile.self,
            ProgressPhoto.self,
            DailyLog.self,
            Routine.self,
            GamificationState.self,
            Quest.self,
            Badge.self,
        ])

        do {
            let config = ModelConfiguration(schema: schema)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Store corrupted — wipe and recreate
            print("[MaxxApp] SwiftData migration failed, recreating store: \(error)")
            let config = ModelConfiguration(schema: schema)
            // Delete the old store file
            let url = config.url
            try? FileManager.default.removeItem(at: url)
            // Also remove WAL/SHM
            try? FileManager.default.removeItem(at: url.appendingPathExtension("wal"))
            try? FileManager.default.removeItem(at: url.appendingPathExtension("shm"))
            // Retry — if this also fails, we truly can't recover
            do {
                modelContainer = try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("[MaxxApp] Cannot create SwiftData store even after reset: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(subscriptionManager)
        }
        .modelContainer(modelContainer)
    }
}
