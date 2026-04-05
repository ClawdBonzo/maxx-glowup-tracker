import SwiftUI
import SwiftData

@main
struct MaxxApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            UserProfile.self,
            ProgressPhoto.self,
            DailyLog.self,
            Routine.self,
        ])
    }
}
