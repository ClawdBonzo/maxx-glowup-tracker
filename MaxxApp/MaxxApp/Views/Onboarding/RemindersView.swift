import SwiftUI

/// Onboarding step that asks for a daily reminder time and requests notification
/// permission at the moment of peak motivation — the single biggest retention lever.
struct RemindersView: View {
    let viewModel: OnboardingViewModel
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.maxxPrimary.opacity(0.12))
                    .frame(width: 110, height: 110)
                    .neonGlow(color: .maxxPrimary, radius: 16)

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.maxxPrimary, .maxxCyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.bottom, 28)

            Text("Stay Consistent")
                .font(.largeTitle)
                .fontWeight(.black)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.maxxSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("People who set a daily reminder are far more likely to stick with their glow-up. When should we nudge you?")
                .font(.subheadline)
                .foregroundColor(.maxxTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
                .padding(.top, 10)

            VStack(spacing: 16) {
                Toggle(isOn: Bindable(viewModel).reminderEnabled) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.maxxAccent)
                        Text("Daily Reminder")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .tint(.maxxPrimary)

                if viewModel.reminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: Bindable(viewModel).reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .foregroundColor(.white)
                    .tint(.maxxPrimary)
                }
            }
            .padding(20)
            .neonCard(cornerRadius: 20, glowColor: .maxxPrimary)
            .padding(.horizontal, 28)
            .padding(.top, 32)

            Spacer()

            Button {
                continueAction()
            } label: {
                if isRequesting {
                    ProgressView().tint(.white)
                } else {
                    Text(viewModel.reminderEnabled ? "Enable Reminders" : "Continue")
                }
            }
            .buttonStyle(.maxxPrimary())
            .disabled(isRequesting)
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
    }

    private func continueAction() {
        guard viewModel.reminderEnabled else {
            viewModel.nextStep()
            return
        }
        isRequesting = true
        Task {
            let granted = await NotificationService.shared.requestPermission()
            if granted {
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: viewModel.reminderTime)
                let minute = calendar.component(.minute, from: viewModel.reminderTime)
                NotificationService.shared.scheduleDailyReminder(at: hour, minute: minute)
                NotificationService.shared.scheduleStreakReminder()
            } else {
                viewModel.reminderEnabled = false
            }
            isRequesting = false
            viewModel.nextStep()
        }
    }
}
