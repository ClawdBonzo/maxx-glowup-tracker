import SwiftUI
import SwiftData

@Observable
@MainActor
final class OnboardingViewModel {
    // MARK: - Onboarding State

    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case gender
        case goals
        case focusAreas
        case age
        case commitment
        case analyzing
        case paywall
    }

    var currentStep: OnboardingStep = .welcome
    var selectedGender: Gender?
    var selectedGoal: GlowUpGoal?
    var selectedFocusAreas: Set<GlowUpCategory> = []
    var age: Int = 22
    var selectedCommitment: CommitmentLevel?
    var analysisProgress: Double = 0
    var showPaywall = false
    var isAnalyzing = false

    var progress: Double {
        Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }

    var canProceed: Bool {
        switch currentStep {
        case .welcome: true
        case .gender: selectedGender != nil
        case .goals: selectedGoal != nil
        case .focusAreas: !selectedFocusAreas.isEmpty
        case .age: age >= 13 && age <= 99
        case .commitment: selectedCommitment != nil
        case .analyzing: false
        case .paywall: true
        }
    }

    // MARK: - Navigation

    func nextStep() {
        guard let nextIndex = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        HapticService.impact(.light)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            currentStep = nextIndex
        }

        if currentStep == .analyzing {
            startAnalysis()
        }
    }

    func previousStep() {
        guard let prevIndex = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            currentStep = prevIndex
        }
    }

    // MARK: - Selections

    func selectGender(_ gender: Gender) {
        HapticService.selection()
        selectedGender = gender
    }

    func selectGoal(_ goal: GlowUpGoal) {
        HapticService.selection()
        selectedGoal = goal
    }

    func toggleFocusArea(_ area: GlowUpCategory) {
        HapticService.selection()
        if selectedFocusAreas.contains(area) {
            selectedFocusAreas.remove(area)
        } else {
            selectedFocusAreas.insert(area)
        }
    }

    func selectCommitment(_ level: CommitmentLevel) {
        HapticService.selection()
        selectedCommitment = level
    }

    // MARK: - Analysis Animation

    func startAnalysis() {
        isAnalyzing = true
        analysisProgress = 0

        Task {
            let steps = 20
            for i in 1...steps {
                try? await Task.sleep(for: .milliseconds(150))
                withAnimation(.easeInOut(duration: 0.3)) {
                    analysisProgress = Double(i) / Double(steps)
                }
            }

            try? await Task.sleep(for: .milliseconds(500))
            HapticService.success()

            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                currentStep = .paywall
            }
            isAnalyzing = false
        }
    }

    // MARK: - Complete Onboarding

    func completeOnboarding(modelContext: ModelContext) -> UserProfile {
        let profile = UserProfile(
            gender: selectedGender?.rawValue,
            age: age,
            primaryGoal: selectedGoal?.rawValue,
            focusAreas: selectedFocusAreas.map(\.rawValue),
            commitmentLevel: selectedCommitment?.rawValue,
            hasCompletedOnboarding: true
        )

        modelContext.insert(profile)

        // Insert default routines
        let defaults = Routine.defaultRoutines()
        for routine in defaults {
            modelContext.insert(routine)
        }

        // Create today's daily log
        let todayLog = DailyLog()
        modelContext.insert(todayLog)

        try? modelContext.save()
        HapticService.success()

        return profile
    }

    // MARK: - Analysis Messages

    var analysisMessages: [(String, String)] {
        [
            ("Analyzing your profile...", "face.smiling"),
            ("Building your routine...", "checklist"),
            ("Personalizing recommendations...", "wand.and.stars"),
            ("Calculating glow-up potential...", "sparkles"),
            ("Preparing your plan...", "doc.text.fill"),
        ]
    }

    var currentAnalysisMessage: (String, String) {
        let index = min(Int(analysisProgress * Double(analysisMessages.count)), analysisMessages.count - 1)
        return analysisMessages[index]
    }
}
