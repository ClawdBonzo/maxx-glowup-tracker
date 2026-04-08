import SwiftUI

struct AnalyzingView: View {
    let viewModel: OnboardingViewModel
    @State private var animate = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Hero illustration
            Image("Onboarding3Analyzing")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 180)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .maxxPrimary.opacity(0.3), radius: 16)
                .rotationEffect(.degrees(rotationAngle * 0.02))

            // Progress ring overlay
            ZStack {
                Circle()
                    .stroke(Color.maxxSurfaceLight, lineWidth: 6)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: viewModel.analysisProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.maxxPrimary, .maxxAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.analysisProgress)

                Text("\(Int(viewModel.analysisProgress * 100))%")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
            }

            // Analysis message
            VStack(spacing: 12) {
                Text(viewModel.currentAnalysisMessage.0)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .contentTransition(.opacity)

                Text("Personalizing your glow-up plan...")
                    .font(.subheadline)
                    .foregroundColor(.maxxTextSecondary)
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.analysisProgress)

            // Analysis items
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(viewModel.analysisMessages.enumerated()), id: \.offset) { index, message in
                    let isComplete = Double(index) / Double(viewModel.analysisMessages.count) < viewModel.analysisProgress
                    let isCurrent = abs(Double(index) / Double(viewModel.analysisMessages.count) - viewModel.analysisProgress) < 0.25

                    HStack(spacing: 14) {
                        Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isComplete ? .maxxSuccess : .maxxTextMuted)
                            .font(.body)

                        Text(message.0)
                            .font(.subheadline)
                            .foregroundColor(isCurrent || isComplete ? .white : .maxxTextMuted)

                        Spacer()
                    }
                    .opacity(animate ? 1 : 0)
                    .animation(
                        .spring(response: 0.5).delay(Double(index) * 0.1),
                        value: animate
                    )
                }
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .onAppear {
            animate = true
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}
