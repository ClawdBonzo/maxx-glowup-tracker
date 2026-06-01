import SwiftUI

struct GenderSelectionView: View {
    let viewModel: OnboardingViewModel
    @State private var animate = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero icon
            Text("👤")
                .font(.system(size: 52))
                .scaleEffect(animate ? 1 : 0.4)
                .opacity(animate ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.02), value: animate)

            // Header
            VStack(spacing: 8) {
                Text("How do you identify?")
                    .font(.title2).fontWeight(.bold).foregroundColor(.white)
                Text("This helps us personalize your routines")
                    .font(.subheadline).foregroundColor(.maxxTextSecondary)
            }
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 14)
            .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.1), value: animate)
            .padding(.top, 16)

            // Options
            VStack(spacing: 12) {
                ForEach(Array(Gender.allCases.enumerated()), id: \.element) { index, gender in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectGender(gender)
                        }
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: gender.icon)
                                .font(.title2)
                                .frame(width: 32)

                            Text(gender.displayName)
                                .font(.body).fontWeight(.semibold)

                            Spacer()

                            if viewModel.selectedGender == gender {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.maxxPrimary)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20).padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(viewModel.selectedGender == gender
                                      ? Color.maxxPrimary.opacity(0.15)
                                      : Color.maxxSurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    viewModel.selectedGender == gender
                                    ? Color.maxxPrimary : Color.white.opacity(0.06),
                                    lineWidth: viewModel.selectedGender == gender ? 2 : 1
                                )
                        )
                        .scaleEffect(viewModel.selectedGender == gender ? 1.02 : 1.0)
                    }
                    .animation(.spring(response: 0.3), value: viewModel.selectedGender)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 16)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.78).delay(0.18 + Double(index) * 0.07),
                        value: animate
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

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
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: animate)
        }
        .onAppear {
            animate = false
            withAnimation { animate = true }
        }
    }
}
