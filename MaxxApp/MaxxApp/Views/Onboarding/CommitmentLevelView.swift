import SwiftUI

struct CommitmentLevelView: View {
    let viewModel: OnboardingViewModel
    @State private var animate = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Text("Your commitment level?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Be honest — we'll match your pace")
                    .font(.subheadline)
                    .foregroundColor(.maxxTextSecondary)
            }
            .opacity(animate ? 1 : 0)

            VStack(spacing: 14) {
                ForEach(Array(CommitmentLevel.allCases.enumerated()), id: \.element) { index, level in
                    let isSelected = viewModel.selectedCommitment == level

                    Button {
                        viewModel.selectCommitment(level)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: level.icon)
                                .font(.title2)
                                .foregroundColor(isSelected ? .maxxPrimary : .maxxTextSecondary)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(level.rawValue)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)

                                Text(level.minutesPerDay)
                                    .font(.caption)
                                    .foregroundColor(.maxxTextSecondary)
                            }

                            Spacer()

                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.maxxPrimary)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            isSelected
                            ? Color.maxxPrimary.opacity(0.15)
                            : Color.maxxSurface
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    isSelected
                                    ? Color.maxxPrimary
                                    : Color.white.opacity(0.06),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                        .delay(Double(index) * 0.08),
                        value: animate
                    )
                    .animation(.spring(response: 0.3), value: isSelected)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 16) {
                Button {
                    viewModel.nextStep()
                } label: {
                    Text("Build My Plan")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            viewModel.canProceed
                            ? AnyShapeStyle(Color.maxxGradient)
                            : AnyShapeStyle(Color.maxxSurfaceLight)
                        )
                        .clipShape(Capsule())
                }
                .disabled(!viewModel.canProceed)

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
}
