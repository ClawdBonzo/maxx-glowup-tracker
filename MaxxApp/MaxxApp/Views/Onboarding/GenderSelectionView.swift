import SwiftUI

struct GenderSelectionView: View {
    let viewModel: OnboardingViewModel
    @State private var animate = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Header
            VStack(spacing: 12) {
                Text("How do you identify?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("This helps us personalize your routines")
                    .font(.subheadline)
                    .foregroundColor(.maxxTextSecondary)
            }
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 20)

            // Gender Options
            VStack(spacing: 14) {
                ForEach(Array(Gender.allCases.enumerated()), id: \.element) { index, gender in
                    Button {
                        viewModel.selectGender(gender)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: gender.icon)
                                .font(.title2)
                                .frame(width: 32)

                            Text(gender.rawValue)
                                .font(.body)
                                .fontWeight(.semibold)

                            Spacer()

                            if viewModel.selectedGender == gender {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.maxxPrimary)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(
                            viewModel.selectedGender == gender
                            ? Color.maxxPrimary.opacity(0.15)
                            : Color.maxxSurface
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    viewModel.selectedGender == gender
                                    ? Color.maxxPrimary
                                    : Color.white.opacity(0.06),
                                    lineWidth: viewModel.selectedGender == gender ? 2 : 1
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
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            // Continue Button
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
