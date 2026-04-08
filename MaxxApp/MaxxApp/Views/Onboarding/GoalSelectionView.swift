import SwiftUI

struct GoalSelectionView: View {
    let viewModel: OnboardingViewModel
    @State private var animate = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Text("What's your goal?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("We'll build your plan around this")
                    .font(.subheadline)
                    .foregroundColor(.maxxTextSecondary)
            }
            .opacity(animate ? 1 : 0)

            VStack(spacing: 12) {
                ForEach(Array(GlowUpGoal.allCases.enumerated()), id: \.element.id) { index, goal in
                    Button {
                        viewModel.selectGoal(goal)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: goal.icon)
                                .font(.title2)
                                .foregroundColor(.maxxPrimary)
                                .frame(width: 36)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(goal.rawValue)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)

                                Text(goal.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.maxxTextSecondary)
                            }

                            Spacer()

                            if viewModel.selectedGoal == goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.maxxPrimary)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            viewModel.selectedGoal == goal
                            ? Color.maxxPrimary.opacity(0.15)
                            : Color.maxxSurface
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    viewModel.selectedGoal == goal
                                    ? Color.maxxPrimary
                                    : Color.white.opacity(0.06),
                                    lineWidth: viewModel.selectedGoal == goal ? 2 : 1
                                )
                        )
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                        .delay(Double(index) * 0.06),
                        value: animate
                    )
                }
            }
            .padding(.horizontal, 24)

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
