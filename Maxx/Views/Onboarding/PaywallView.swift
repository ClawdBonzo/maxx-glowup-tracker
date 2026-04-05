import SwiftUI

struct PaywallView: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void
    @State private var animate = false
    @State private var selectedPlan: PaywallPlan = .yearly

    enum PaywallPlan: String, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"

        var price: String {
            switch self {
            case .weekly: "$4.99/wk"
            case .monthly: "$9.99/mo"
            case .yearly: "$39.99/yr"
            }
        }

        var savings: String? {
            switch self {
            case .weekly: nil
            case .monthly: "Save 50%"
            case .yearly: "Save 85%"
            }
        }

        var weeklyEquivalent: String {
            switch self {
            case .weekly: "$4.99"
            case .monthly: "$2.50"
            case .yearly: "$0.77"
            }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                // Close / Skip
                HStack {
                    Spacer()
                    Button {
                        onContinue()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.maxxTextMuted)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Crown icon
                ZStack {
                    Circle()
                        .fill(Color.maxxGold.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "F9CA24"), Color(hex: "F0932B")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .opacity(animate ? 1 : 0)
                .scaleEffect(animate ? 1 : 0.5)

                // Header
                VStack(spacing: 8) {
                    Text("Unlock Maxx Pro")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Maximize your glow-up potential")
                        .font(.subheadline)
                        .foregroundColor(.maxxTextSecondary)
                }
                .opacity(animate ? 1 : 0)

                // Features
                VStack(spacing: 14) {
                    proFeature(icon: "infinity", title: "Unlimited Progress Photos", subtitle: "Track every angle, every day")
                    proFeature(icon: "chart.line.uptrend.xyaxis", title: "Advanced Analytics", subtitle: "Deep insights into your progress")
                    proFeature(icon: "wand.and.stars", title: "Premium Routines", subtitle: "Expert-curated glow-up plans")
                    proFeature(icon: "camera.filters", title: "Photo Comparison", subtitle: "Side-by-side before & after")
                    proFeature(icon: "bell.badge.fill", title: "Smart Reminders", subtitle: "Never miss a routine again")
                    proFeature(icon: "lock.open.fill", title: "All Future Features", subtitle: "Get everything we build, forever")
                }
                .padding(.horizontal, 20)
                .opacity(animate ? 1 : 0)

                // Plan selection
                VStack(spacing: 10) {
                    ForEach(PaywallPlan.allCases, id: \.self) { plan in
                        let isSelected = selectedPlan == plan

                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPlan = plan
                            }
                            HapticService.selection()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Text(plan.rawValue)
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)

                                        if let savings = plan.savings {
                                            Text(savings)
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.maxxBackground)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(Color.maxxGold)
                                                .clipShape(Capsule())
                                        }
                                    }

                                    Text("\(plan.weeklyEquivalent)/week")
                                        .font(.caption)
                                        .foregroundColor(.maxxTextSecondary)
                                }

                                Spacer()

                                Text(plan.price)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                isSelected
                                ? Color.maxxPrimary.opacity(0.15)
                                : Color.maxxSurface
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(
                                        isSelected ? Color.maxxPrimary : Color.white.opacity(0.06),
                                        lineWidth: isSelected ? 2 : 1
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .opacity(animate ? 1 : 0)

                // Subscribe button
                Button {
                    // TODO: RevenueCat purchase flow
                    // Replace with: Purchases.shared.purchase(package:)
                    onContinue()
                } label: {
                    Text("Start Free Trial")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.maxxGoldGradient)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)

                // Trial info
                VStack(spacing: 6) {
                    Text("3-day free trial, then \(selectedPlan.price)")
                        .font(.caption)
                        .foregroundColor(.maxxTextSecondary)

                    Text("Cancel anytime. No commitment.")
                        .font(.caption2)
                        .foregroundColor(.maxxTextMuted)
                }

                // Skip button
                Button {
                    onContinue()
                } label: {
                    Text("Continue with free version")
                        .font(.subheadline)
                        .foregroundColor(.maxxTextMuted)
                        .underline()
                }
                .padding(.bottom, 20)

                // Legal
                HStack(spacing: 16) {
                    Button("Terms") { }
                        .font(.caption2)
                        .foregroundColor(.maxxTextMuted)

                    Button("Privacy") { }
                        .font(.caption2)
                        .foregroundColor(.maxxTextMuted)

                    Button("Restore") {
                        // TODO: Purchases.shared.restorePurchases()
                    }
                    .font(.caption2)
                    .foregroundColor(.maxxTextMuted)
                }
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                animate = true
            }
        }
    }

    private func proFeature(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.maxxGold)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.maxxTextSecondary)
            }

            Spacer()
        }
    }
}
