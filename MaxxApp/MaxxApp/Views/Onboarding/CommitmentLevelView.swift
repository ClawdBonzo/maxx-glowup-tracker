import SwiftUI

struct CommitmentLevelView: View {
    let viewModel: OnboardingViewModel
    @State private var animate = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero icon
            Text("💪")
                .font(.system(size: 52))
                .scaleEffect(animate ? 1 : 0.4)
                .opacity(animate ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.02), value: animate)

            // Header
            VStack(spacing: 8) {
                Text("Your commitment level?")
                    .font(.title2).fontWeight(.bold).foregroundColor(.white)
                Text("Be honest — we'll match your pace")
                    .font(.subheadline).foregroundColor(.maxxTextSecondary)
            }
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 14)
            .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.1), value: animate)
            .padding(.top, 16)

            // Options
            VStack(spacing: 12) {
                ForEach(Array(CommitmentLevel.allCases.enumerated()), id: \.element) { index, level in
                    let isSelected = viewModel.selectedCommitment == level

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectCommitment(level)
                        }
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(isSelected ? Color.maxxPrimary.opacity(0.2) : Color.maxxSurfaceLight)
                                    .frame(width: 44, height: 44)
                                Image(systemName: level.icon)
                                    .font(.body)
                                    .foregroundColor(isSelected ? .maxxPrimary : .maxxTextSecondary)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(level.displayName)
                                    .font(.body).fontWeight(.semibold).foregroundColor(.white)
                                Text(level.minutesPerDay)
                                    .font(.caption).foregroundColor(.maxxTextSecondary)
                            }

                            Spacer()

                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.maxxPrimary)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(isSelected ? Color.maxxPrimary.opacity(0.12) : Color.maxxSurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    isSelected ? Color.maxxPrimary : Color.white.opacity(0.06),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                        .scaleEffect(isSelected ? 1.02 : 1.0)
                    }
                    .animation(.spring(response: 0.28, dampingFraction: 0.7), value: isSelected)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 14)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.78).delay(0.18 + Double(index) * 0.07),
                        value: animate
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()

            // Navigation
            VStack(spacing: 14) {
                Button { viewModel.nextStep() } label: {
                    Text("Build My Plan")
                        .font(.headline).fontWeight(.bold).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(viewModel.canProceed ? AnyShapeStyle(Color.maxxGradient) : AnyShapeStyle(Color.maxxSurfaceLight))
                        .clipShape(Capsule())
                }
                .disabled(!viewModel.canProceed)
                .animation(.easeInOut(duration: 0.2), value: viewModel.canProceed)

                Button("Back") { viewModel.previousStep() }
                    .font(.subheadline).foregroundColor(.maxxTextMuted)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .opacity(animate ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5), value: animate)
        }
        .onAppear {
            animate = false
            withAnimation { animate = true }
        }
    }
}
