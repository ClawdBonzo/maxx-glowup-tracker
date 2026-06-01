import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subManager
    @Query private var profiles: [UserProfile]
    @State private var showResetAlert = false
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    @State private var showPaywall = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            List {
                // Profile section
                Section {
                    HStack(spacing: 16) {
                        Image("MaxxLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: .maxxPrimary.opacity(0.3), radius: 8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Day \(profile?.daysSinceJoined ?? 0)")
                                .font(.headline)
                                .foregroundColor(.white)

                            if let goal = profile?.parsedGoal {
                                Text(goal.displayName)
                                    .font(.caption)
                                    .foregroundColor(.maxxTextSecondary)
                            }

                            if let commitment = profile?.parsedCommitment {
                                Text(commitment.displayName + " • " + commitment.minutesPerDay)
                                    .font(.caption)
                                    .foregroundColor(.maxxTextMuted)
                            }
                        }
                    }
                    .listRowBackground(Color.maxxSurface)
                }

                // Premium
                Section("Premium") {
                    if subManager.isPremium {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.maxxGold)
                            Text("Maxx Pro Active")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.maxxSuccess)
                        }
                        .listRowBackground(Color.maxxSurface)
                    } else {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.maxxGold)
                                Text("Upgrade to Pro")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.maxxTextMuted)
                            }
                        }
                        .listRowBackground(Color.maxxSurface)
                    }

                    Button {
                        Task { await subManager.restorePurchases() }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.maxxPrimary)
                            Text("Restore Purchases")
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(Color.maxxSurface)
                }

                // Reminders
                Section("Reminders") {
                    Toggle(isOn: $reminderEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.maxxAccent)
                            Text("Daily Reminder")
                                .foregroundColor(.white)
                        }
                    }
                    .tint(.maxxPrimary)
                    .listRowBackground(Color.maxxSurface)
                    .onChange(of: reminderEnabled) { _, enabled in
                        if enabled {
                            Task {
                                let granted = await NotificationService.shared.requestPermission()
                                if granted {
                                    let calendar = Calendar.current
                                    let hour = calendar.component(.hour, from: reminderTime)
                                    let minute = calendar.component(.minute, from: reminderTime)
                                    NotificationService.shared.scheduleDailyReminder(at: hour, minute: minute)
                                } else {
                                    reminderEnabled = false
                                }
                            }
                        } else {
                            NotificationService.shared.cancelAllReminders()
                        }
                    }

                    if reminderEnabled {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .foregroundColor(.white)
                            .listRowBackground(Color.maxxSurface)
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                            .foregroundColor(.white)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.maxxTextMuted)
                    }
                    .listRowBackground(Color.maxxSurface)

                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.maxxSuccess)
                        Text("All data stored locally on your device")
                            .font(.subheadline)
                            .foregroundColor(.maxxTextSecondary)
                    }
                    .listRowBackground(Color.maxxSurface)
                }

                // Danger Zone
                Section("Data") {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.maxxError)
                            Text("Reset All Data")
                                .foregroundColor(.maxxError)
                        }
                    }
                    .listRowBackground(Color.maxxSurface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.maxxBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all your progress photos, routines, logs, and profile data. This cannot be undone.")
            }
        }
    }

    private func resetAllData() {
        try? modelContext.delete(model: UserProfile.self)
        try? modelContext.delete(model: ProgressPhoto.self)
        try? modelContext.delete(model: DailyLog.self)
        try? modelContext.delete(model: Routine.self)
        try? modelContext.save()
        HapticService.impact(.heavy)
    }
}
