import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        ZStack {
            Color.maxxBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                if viewModel.currentStep != .welcome && viewModel.currentStep != .analyzing {
                    onboardingProgressBar
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }

                // Content
                TabView(selection: $viewModel.currentStep) {
                    WelcomeView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.welcome)

                    GenderSelectionView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.gender)

                    GoalSelectionView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.goals)

                    FocusAreaSelectionView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.focusAreas)

                    AgeInputView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.age)

                    CommitmentLevelView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.commitment)

                    AnalyzingView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.analyzing)

                    PaywallView(viewModel: viewModel) {
                        completeOnboarding()
                    }
                    .tag(OnboardingViewModel.OnboardingStep.paywall)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.currentStep)
                .disabled(viewModel.currentStep == .analyzing)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Progress Bar

    private var onboardingProgressBar: some View {
        HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { index in
                Capsule()
                    .fill(index <= viewModel.currentStep.rawValue - 1
                          ? Color.maxxPrimary
                          : Color.maxxSurfaceLight)
                    .frame(height: 4)
            }
        }
        .animation(.spring(response: 0.3), value: viewModel.currentStep)
    }

    // MARK: - Complete

    private func completeOnboarding() {
        _ = viewModel.completeOnboarding(modelContext: modelContext)
        withAnimation(.spring(response: 0.5)) {
            hasCompletedOnboarding = true
        }
    }
}
