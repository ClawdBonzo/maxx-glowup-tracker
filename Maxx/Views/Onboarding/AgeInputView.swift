import SwiftUI

struct AgeInputView: View {
    let viewModel: OnboardingViewModel
    @State private var animate = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 12) {
                Text("How old are you?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Your plan adapts to your age")
                    .font(.subheadline)
                    .foregroundColor(.maxxTextSecondary)
            }
            .opacity(animate ? 1 : 0)

            // Age display
            VStack(spacing: 24) {
                Text("\(viewModel.age)")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.maxxPrimary, .maxxAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3), value: viewModel.age)

                // Age slider
                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.age) },
                            set: { viewModel.age = Int($0) }
                        ),
                        in: 13...65,
                        step: 1
                    )
                    .tint(.maxxPrimary)
                    .padding(.horizontal, 40)

                    HStack {
                        Text("13")
                        Spacer()
                        Text("65")
                    }
                    .font(.caption)
                    .foregroundColor(.maxxTextMuted)
                    .padding(.horizontal, 40)
                }
            }
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 20)

            // Age insight
            Text(ageInsight)
                .font(.subheadline)
                .foregroundColor(.maxxTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(animate ? 1 : 0)

            Spacer()

            VStack(spacing: 16) {
                Button {
                    viewModel.nextStep()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.maxxGradient)
                        .clipShape(Capsule())
                }

                Button("Back") {
                    viewModel.previousStep()
                }
                .font(.subheadline)
                .foregroundColor(.maxxTextMuted)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animate = true
            }
        }
        .onDisappear { animate = false }
    }

    private var ageInsight: String {
        switch viewModel.age {
        case 13...17:
            "Great time to build healthy habits early. Your skin and body are still developing!"
        case 18...24:
            "Prime glow-up years. Consistency now pays massive dividends later."
        case 25...34:
            "Focus on prevention and maintenance. Skincare and fitness compound over time."
        case 35...44:
            "Anti-aging routines become key. You'll see incredible results with the right approach."
        default:
            "It's never too late to level up. Small changes make a huge difference."
        }
    }
}
