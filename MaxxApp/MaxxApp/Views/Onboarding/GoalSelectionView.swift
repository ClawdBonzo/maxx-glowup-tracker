import SwiftUI

struct GoalSelectionView: View {
    let viewModel: OnboardingViewModel
    @State private var animate = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero icon
            Text("🎯")
                .font(.system(size: 52))
                .scaleEffect(animate ? 1 : 0.4)
                .opacity(animate ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.02), value: animate)

            // Header
            VStack(spacing: 8) {
                Text("What's your goal?")
                    .font(.title2).fontWeight(.bold).foregroundColor(.white)
                Text("We'll build your plan around this")
                    .font(.subheadline).foregroundColor(.maxxTextSecondary)
            }
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 14)
            .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.1), value: animate)
            .padding(.top, 16)

            // Options
            VStack(spacing: 10) {
                ForEach(Array(GlowUpGoal.allCases.enumerated()), id: \.element.id) { index, goal in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectGoal(goal)
                        }
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(viewModel.selectedGoal == goal
                                          ? Color.maxxPrimary.opacity(0.2)
                                          : Color.maxxSurfaceLight)
                                    .frame(width: 42, height: 42)
                                Image(systemName: goal.icon)
                                    .font(.body)
                                    .foregroundColor(viewModel.selectedGoal == goal ? .maxxPrimary : .maxxTextSecondary)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(goal.displayName)
                                    .font(.body).fontWeight(.semibold).foregroundColor(.white)
                                Text(goal.subtitle)
                                    .font(.caption).foregroundColor(.maxxTextSecondary)
                            }

                            Spacer()

                            if viewModel.selectedGoal == goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.maxxPrimary)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(viewModel.selectedGoal == goal
                                      ? Color.maxxPrimary.opacity(0.12)
                                      : Color.maxxSurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    viewModel.selectedGoal == goal ? Color.maxxPrimary : Color.white.opacity(0.06),
                                    lineWidth: viewModel.selectedGoal == goal ? 2 : 1
                                )
                        )
                        .scaleEffect(viewModel.selectedGoal == goal ? 1.02 : 1.0)
                    }
                    .animation(.spring(response: 0.3), value: viewModel.selectedGoal)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 14)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.78).delay(0.18 + Double(index) * 0.06),
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
                    Text("Continue")
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
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.45), value: animate)
        }
        .onAppear {
            animate = false
            withAnimation { animate = true }
        }
    }
}
