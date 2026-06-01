import SwiftUI

// MARK: - Free Tier Limits

enum FreeTierLimits {
    static let maxRoutines = 3
    static let maxPhotos = 5
}

// MARK: - Premium Gate View (Contextual Mini-Paywall)

/// A lightweight paywall sheet shown when free users hit a limit or tap a Pro feature.
struct PremiumGateView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var subManager = SubscriptionManager.shared
    @State private var isPurchasing = false

    let feature: ProFeature

    enum ProFeature {
        case routines
        case photos
        case mirrorMode
        case photoCompare
        case quests
        case badges
        case shareCard
        case analytics

        var icon: String {
            switch self {
            case .routines:     "checkmark.circle.fill"
            case .photos:       "camera.fill"
            case .mirrorMode:   "camera.filters"
            case .photoCompare: "rectangle.on.rectangle"
            case .quests:       "checklist"
            case .badges:       "star.fill"
            case .shareCard:    "square.and.arrow.up"
            case .analytics:    "chart.line.uptrend.xyaxis"
            }
        }

        var title: String {
            switch self {
            case .routines:     String(localized: "gate.routines.title", defaultValue: "Unlock Unlimited Routines")
            case .photos:       String(localized: "gate.photos.title", defaultValue: "Unlock Unlimited Photos")
            case .mirrorMode:   String(localized: "gate.mirrorMode.title", defaultValue: "Unlock Mirror Mode")
            case .photoCompare: String(localized: "gate.photoCompare.title", defaultValue: "Unlock Photo Compare")
            case .quests:       String(localized: "gate.quests.title", defaultValue: "Unlock Quests")
            case .badges:       String(localized: "gate.badges.title", defaultValue: "Unlock Badges")
            case .shareCard:    String(localized: "gate.shareCard.title", defaultValue: "Unlock Share Cards")
            case .analytics:    String(localized: "gate.analytics.title", defaultValue: "Unlock Glow Analytics")
            }
        }

        var subtitle: String {
            switch self {
            case .routines:     String(localized: "gate.routines.subtitle", defaultValue: "Free plan is limited to \(FreeTierLimits.maxRoutines) routines. Go Pro for unlimited custom routines.")
            case .photos:       String(localized: "gate.photos.subtitle", defaultValue: "Free plan is limited to \(FreeTierLimits.maxPhotos) photos. Go Pro for unlimited progress tracking.")
            case .mirrorMode:   String(localized: "gate.mirrorMode.subtitle", defaultValue: "Align your angles with the golden ratio grid. A Pro-only tool for serious glow-ups.")
            case .photoCompare: String(localized: "gate.photoCompare.subtitle", defaultValue: "See your transformation side-by-side. Upgrade to compare progress photos.")
            case .quests:       String(localized: "gate.quests.subtitle", defaultValue: "Daily quests keep your glow-up on track. Upgrade to unlock challenges and bonus XP.")
            case .badges:       String(localized: "gate.badges.subtitle", defaultValue: "Earn badges for your achievements. Upgrade to start your collection.")
            case .shareCard:    String(localized: "gate.shareCard.subtitle", defaultValue: "Show off your glow-up level. Upgrade to create and share progress cards.")
            case .analytics:    String(localized: "gate.analytics.subtitle", defaultValue: "Track your glow score and mood trends over time. Upgrade for charts and insights.")
            }
        }

        var accentColor: Color {
            switch self {
            case .routines:     .maxxCyan
            case .photos:       .maxxPrimary
            case .mirrorMode:   .maxxGold
            case .photoCompare: .maxxCyan
            case .quests:       .maxxCyan
            case .badges:       .maxxGold
            case .shareCard:    .maxxPrimary
            case .analytics:    .maxxCyan
            }
        }
    }

    var body: some View {
        ZStack {
            Color.maxxBackground.ignoresSafeArea()

            RadialGradient(
                colors: [feature.accentColor.opacity(0.18), .clear],
                center: .top, startRadius: 0, endRadius: 350
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(feature.accentColor.opacity(0.12))
                        .frame(width: 100, height: 100)

                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [feature.accentColor, feature.accentColor.opacity(0.4)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: 100, height: 100)

                    Image(systemName: feature.icon)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [feature.accentColor, .white],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                }

                // Text
                VStack(spacing: 10) {
                    Text(feature.title)
                        .font(.title3)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(feature.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.maxxTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                // Pro badge
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                        .foregroundColor(.maxxGold)
                    Text("MAXX PRO")
                        .font(.system(size: 12, weight: .black))
                        .tracking(1.5)
                        .foregroundColor(.maxxGold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.maxxGold.opacity(0.10))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.maxxGold.opacity(0.3), lineWidth: 1)
                )

                Spacer()

                // CTA buttons
                VStack(spacing: 12) {
                    Button {
                        Task { await handlePurchase() }
                    } label: {
                        HStack(spacing: 8) {
                            if isPurchasing {
                                ProgressView().tint(.white).scaleEffect(0.85)
                            } else {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Start Free Trial")
                                    .font(.headline).fontWeight(.heavy)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            LinearGradient(
                                colors: [.maxxPrimary, Color(hex: "6B0FD4")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .maxxPrimary.opacity(0.50), radius: 16, y: 6)
                    }
                    .disabled(isPurchasing)

                    Text("3 days free, then $9.99/month. Auto-renews until canceled; cancel anytime in Settings.")
                        .font(.caption)
                        .foregroundColor(.maxxTextSecondary)

                    if let err = subManager.errorMessage {
                        Text(err)
                            .font(.caption2)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button("Not now") { dismiss() }
                        .font(.system(size: 13))
                        .foregroundColor(.maxxTextMuted)
                        .padding(.top, 4)

                    HStack(spacing: 0) {
                        Button("Restore") { Task { await subManager.restorePurchases() } }
                        Text(" · ").foregroundColor(.maxxTextMuted)
                        Button("Terms") { openURL(URL(string: "https://gwlabs.app/terms")!) }
                        Text(" · ").foregroundColor(.maxxTextMuted)
                        Button("Privacy") { openURL(URL(string: "https://gwlabs.app/privacy")!) }
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.maxxTextMuted)
                    .padding(.top, 2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            Task { await subManager.fetchOfferings() }
        }
    }

    @MainActor
    private func handlePurchase() async {
        // Try to find the monthly package (best value) or fall back to first available
        let monthly = subManager.packages.first { pkg in
            subManager.isMonthly(pkg)
        }
        guard let pkg = monthly ?? subManager.packages.first else {
            subManager.errorMessage = "Plans unavailable. Check your connection."
            return
        }
        isPurchasing = true
        let success = await subManager.purchase(pkg)
        isPurchasing = false
        if success {
            dismiss()
        }
    }
}
