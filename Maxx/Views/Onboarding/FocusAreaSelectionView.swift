import SwiftUI

struct FocusAreaSelectionView: View {
    let viewModel: OnboardingViewModel
    @State private var animate = false

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 12) {
                Text("Focus areas")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Select all that apply")
                    .font(.subheadline)
                    .foregroundColor(.maxxTextSecondary)
            }
            .opacity(animate ? 1 : 0)

            // Grid of categories
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Array(GlowUpCategory.allCases.enumerated()), id: \.element.id) { index, category in
                    let isSelected = viewModel.selectedFocusAreas.contains(category)

                    Button {
                        viewModel.toggleFocusArea(category)
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: category.icon)
                                .font(.title2)
                                .foregroundColor(
                                    isSelected
                                    ? Color.categoryColor(for: category)
                                    : .maxxTextSecondary
                                )

                            Text(category.rawValue)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            isSelected
                            ? Color.categoryColor(for: category).opacity(0.15)
                            : Color.maxxSurface
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    isSelected
                                    ? Color.categoryColor(for: category)
                                    : Color.white.opacity(0.06),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                        .scaleEffect(isSelected ? 1.02 : 1.0)
                    }
                    .opacity(animate ? 1 : 0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                        .delay(Double(index) * 0.04),
                        value: animate
                    )
                    .animation(.spring(response: 0.3), value: isSelected)
                }
            }
            .padding(.horizontal, 24)

            if !viewModel.selectedFocusAreas.isEmpty {
                Text("\(viewModel.selectedFocusAreas.count) area\(viewModel.selectedFocusAreas.count == 1 ? "" : "s") selected")
                    .font(.caption)
                    .foregroundColor(.maxxPrimary)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

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
