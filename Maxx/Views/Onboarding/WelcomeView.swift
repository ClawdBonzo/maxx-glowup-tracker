import SwiftUI

struct WelcomeView: View {
    let viewModel: OnboardingViewModel
    @State private var animate = false
    @State private var pulseGlow = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Animated Logo
            ZStack {
                // Outer glow ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.maxxPrimary, .maxxAccent, .maxxPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(pulseGlow ? 1.1 : 1.0)
                    .opacity(pulseGlow ? 0.5 : 0.8)

                // Inner circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.maxxPrimary.opacity(0.3), .maxxAccent.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)

                // Icon
                Image(systemName: "sparkles")
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.maxxPrimary, .maxxAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(animate ? 1.0 : 0.5)
                    .opacity(animate ? 1 : 0)
            }
            .padding(.bottom, 10)

            // Title
            VStack(spacing: 16) {
                Text("MAXX")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .tracking(8)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .maxxSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)

                Text("Your Glow-Up Journey\nStarts Now")
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.maxxTextSecondary)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
            }

            // Features preview
            VStack(spacing: 14) {
                featureRow(icon: "camera.fill", text: "Track your visual progress")
                featureRow(icon: "checklist", text: "Build daily glow-up routines")
                featureRow(icon: "chart.line.uptrend.xyaxis", text: "See your transformation over time")
                featureRow(icon: "lock.shield.fill", text: "100% private — never leaves your device")
            }
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 30)

            Spacer()

            // CTA Button
            Button {
                viewModel.nextStep()
            } label: {
                Text("Let's Go")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.maxxGradient)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 40)

            Text("Takes less than 2 minutes")
                .font(.caption)
                .foregroundColor(.maxxTextMuted)
                .opacity(animate ? 1 : 0)
                .padding(.bottom, 20)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animate = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseGlow = true
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.maxxPrimary)
                .frame(width: 28)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.maxxTextSecondary)

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
