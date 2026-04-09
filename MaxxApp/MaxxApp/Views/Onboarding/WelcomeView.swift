import SwiftUI

struct WelcomeView: View {
    let viewModel: OnboardingViewModel
    @State private var animate = false
    @State private var glowPulse = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero illustration
            ZStack {
                // Ambient glow behind image
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(
                        colors: [Color(hex: "6C5CE7").opacity(glowPulse ? 0.35 : 0.2),
                                 Color(hex: "00CEC9").opacity(glowPulse ? 0.25 : 0.1)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(height: 240)
                    .blur(radius: 36)
                    .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: glowPulse)

                Image("Onboarding1Welcome")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Color(hex: "6C5CE7").opacity(0.45), radius: 24, y: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "6C5CE7").opacity(0.5), Color(hex: "00CEC9").opacity(0.3)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            }
            .padding(.horizontal, 24)
            .scaleEffect(animate ? 1.0 : 0.82)
            .opacity(animate ? 1 : 0)
            .animation(.spring(response: 0.75, dampingFraction: 0.7).delay(0.05), value: animate)

            // Headline — no duplicate brand name, straight to the value prop
            VStack(spacing: 10) {
                Text("Your Glow-Up")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 18)
                    .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.18), value: animate)

                Text("Starts Today")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(LinearGradient(
                        colors: [Color(hex: "6C5CE7"), Color(hex: "00CEC9"), Color(hex: "FDCB6E")],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 18)
                    .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.24), value: animate)
            }
            .padding(.top, 28)

            // Feature bullets — staggered in
            VStack(spacing: 12) {
                featureRow(icon: "camera.fill",         text: "Track your visual progress", delay: 0.32)
                featureRow(icon: "checklist",           text: "Build daily glow-up routines",   delay: 0.38)
                featureRow(icon: "flame.fill",          text: "Level up with XP & daily quests", delay: 0.44)
                featureRow(icon: "lock.shield.fill",    text: "100% private — never leaves your device", delay: 0.50)
            }
            .padding(.top, 24)
            .padding(.horizontal, 8)

            Spacer()

            // CTA
            VStack(spacing: 10) {
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
                        .shadow(color: Color(hex: "6C5CE7").opacity(0.4), radius: 12, y: 4)
                }

                Text("Takes less than 2 minutes")
                    .font(.caption)
                    .foregroundColor(.maxxTextMuted)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 24)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.56), value: animate)
        }
        .onAppear {
            withAnimation { animate = true }
            withAnimation(.easeInOut(duration: 0.1)) { glowPulse = true }
        }
    }

    private func featureRow(icon: String, text: String, delay: Double) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.maxxPrimary.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.footnote)
                    .foregroundColor(.maxxPrimary)
            }
            Text(text)
                .font(.subheadline)
                .foregroundColor(.maxxTextSecondary)
            Spacer()
        }
        .padding(.horizontal, 24)
        .opacity(animate ? 1 : 0)
        .offset(x: animate ? 0 : -20)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(delay), value: animate)
    }
}
