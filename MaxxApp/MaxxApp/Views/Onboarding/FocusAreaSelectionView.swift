import SwiftUI

struct FocusAreaSelectionView: View {
    let viewModel: OnboardingViewModel
    @State private var animate = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero icon
            Text("✨")
                .font(.system(size: 52))
                .scaleEffect(animate ? 1 : 0.4)
                .opacity(animate ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.02), value: animate)

            // Header
            VStack(spacing: 8) {
                Text("Focus areas")
                    .font(.title2).fontWeight(.bold).foregroundColor(.white)
                Text("Select all that apply")
                    .font(.subheadline).foregroundColor(.maxxTextSecondary)
            }
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 14)
            .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.1), value: animate)
            .padding(.top, 16)

            // Grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(GlowUpCategory.allCases.enumerated()), id: \.element.id) { index, category in
                    let isSelected = viewModel.selectedFocusAreas.contains(category)

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.toggleFocusArea(category)
                        }
                    } label: {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(isSelected
                                          ? Color.categoryColor(for: category).opacity(0.2)
                                          : Color.maxxSurfaceLight)
                                    .frame(width: 44, height: 44)
                                Image(systemName: category.icon)
                                    .font(.body)
                                    .foregroundColor(isSelected ? Color.categoryColor(for: category) : .maxxTextSecondary)
                            }
                            Text(category.displayName)
                                .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(isSelected ? Color.categoryColor(for: category).opacity(0.12) : Color.maxxSurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    isSelected ? Color.categoryColor(for: category) : Color.white.opacity(0.06),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                        .scaleEffect(isSelected ? 1.03 : 1.0)
                    }
                    .animation(.spring(response: 0.28, dampingFraction: 0.7), value: isSelected)
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1 : 0.88)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.78).delay(0.18 + Double(index) * 0.04),
                        value: animate
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            // Selection count badge
            if !viewModel.selectedFocusAreas.isEmpty {
                Text("\(viewModel.selectedFocusAreas.count) area\(viewModel.selectedFocusAreas.count == 1 ? "" : "s") selected")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundColor(.maxxPrimary)
                    .padding(.top, 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

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
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5), value: animate)
        }
        .onAppear {
            animate = false
            withAnimation { animate = true }
        }
    }
}
