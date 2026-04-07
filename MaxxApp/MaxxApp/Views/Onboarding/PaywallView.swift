import SwiftUI
import RevenueCat

struct PaywallView: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @State private var subManager = SubscriptionManager.shared
    @State private var animate = false
    @State private var selectedPackage: Package?
    @State private var isPurchasing = false
    @State private var showCelebration = false

    var body: some View {
        ZStack {
            // Main paywall content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    closeButton
                    heroSection
                    trialBadge
                    headline
                    featuresList
                    packageCards
                    ctaButton
                    trialDisclaimer
                    skipButton
                    legalFooter
                }
            }
            .opacity(showCelebration ? 0.3 : 1)

            // Celebration overlay
            if showCelebration {
                celebrationOverlay
            }
        }
        .background(Color.maxxBackground.ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                animate = true
            }
            Task { await subManager.fetchOfferings() }
            // Default-select monthly (the BEST VALUE plan)
            selectDefaultPackage()
        }
        .onChange(of: subManager.packages) { _, _ in
            selectDefaultPackage()
        }
    }

    // MARK: - Close / Skip Button

    private var closeButton: some View {
        HStack {
            Spacer()
            Button {
                onContinue()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Hero Illustration (Before/After teaser)

    private var heroSection: some View {
        ZStack {
            // Neon glow behind the image
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "6C5CE7").opacity(0.3),
                            Color(hex: "00CEC9").opacity(0.2),
                            Color(hex: "FDCB6E").opacity(0.15),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 140)
                .blur(radius: 30)

            Image("Onboarding4Paywall")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 140)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "6C5CE7").opacity(0.6),
                                    Color(hex: "00CEC9").opacity(0.4),
                                    Color(hex: "FDCB6E").opacity(0.3),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color(hex: "6C5CE7").opacity(0.4), radius: 24, y: 8)
        }
        .padding(.horizontal, 24)
        .padding(.top, 0)
        .opacity(animate ? 1 : 0)
        .scaleEffect(animate ? 1 : 0.85)
    }

    // MARK: - Free Trial Badge

    private var trialBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "gift.fill")
                .font(.subheadline)

            Text("3-DAY FREE TRIAL")
                .font(.subheadline)
                .fontWeight(.heavy)
                .tracking(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color(hex: "00B894"))
                .shadow(color: Color(hex: "00B894").opacity(0.4), radius: 12, y: 4)
        )
        .padding(.top, 12)
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 10)
    }

    // MARK: - Headline

    private var headline: some View {
        VStack(spacing: 10) {
            Text("Unlock Your Full")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Glow-Up Transformation")
                .font(.title2)
                .fontWeight(.black)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "6C5CE7"), Color(hex: "00CEC9"), Color(hex: "FDCB6E")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .multilineTextAlignment(.center)
        .padding(.top, 10)
        .padding(.horizontal, 20)
        .opacity(animate ? 1 : 0)
    }

    // MARK: - Features List

    private var featuresList: some View {
        VStack(spacing: 12) {
            proFeatureRow(icon: "camera.fill", text: "Unlimited progress photos & comparisons")
            proFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Advanced analytics & glow score insights")
            proFeatureRow(icon: "wand.and.stars", text: "Premium expert-curated routines")
            proFeatureRow(icon: "bell.badge.fill", text: "Smart reminders that keep you consistent")
            proFeatureRow(icon: "lock.open.fill", text: "Every future feature, forever")
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .opacity(animate ? 1 : 0)
    }

    private func proFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark.circle.fill")
                .font(.body)
                .foregroundColor(Color(hex: "00CEC9"))

            Text(text)
                .font(.subheadline)
                .foregroundColor(.maxxTextSecondary)

            Spacer()
        }
    }

    // MARK: - Package Cards

    private var packageCards: some View {
        VStack(spacing: 10) {
            if subManager.packages.isEmpty {
                // Fallback static cards while offerings load
                ForEach(SubscriptionManager.ProductID.allCases, id: \.self) { pid in
                    staticPackageCard(pid)
                }
            } else {
                ForEach(subManager.packages, id: \.identifier) { package in
                    livePackageCard(package)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .opacity(animate ? 1 : 0)
    }

    // Card using live RevenueCat data
    private func livePackageCard(_ package: Package) -> some View {
        let isSelected = selectedPackage?.identifier == package.identifier
        let isBestValue = subManager.isMonthly(package)
        let pid = subManager.productID(for: package)

        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedPackage = package
            }
            HapticService.selection()
        } label: {
            HStack(spacing: 0) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(hex: "00CEC9") : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 22, height: 22)

                    if isSelected {
                        Circle()
                            .fill(Color(hex: "00CEC9"))
                            .frame(width: 14, height: 14)
                    }
                }
                .padding(.trailing, 14)

                // Plan info
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(pid?.displayName ?? package.storeProduct.localizedTitle)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        if let badge = pid?.badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundColor(.maxxBackground)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    isBestValue
                                    ? Color(hex: "00CEC9")
                                    : Color(hex: "FDCB6E")
                                )
                                .clipShape(Capsule())
                        }
                    }

                    if let weeklyEq = subManager.weeklyEquivalent(for: package) {
                        Text("Just \(weeklyEq)")
                            .font(.caption)
                            .foregroundColor(.maxxTextMuted)
                    }

                    if package.packageType == .lifetime {
                        Text("Pay once, own forever")
                            .font(.caption)
                            .foregroundColor(.maxxTextMuted)
                    }
                }

                Spacer()

                // Price
                VStack(alignment: .trailing, spacing: 2) {
                    Text(package.localizedPriceString)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    if package.packageType != .lifetime {
                        Text(periodLabel(package))
                            .font(.caption2)
                            .foregroundColor(.maxxTextMuted)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected
                          ? (isBestValue
                             ? Color(hex: "00CEC9").opacity(0.1)
                             : Color.maxxPrimary.opacity(0.1))
                          : Color.maxxSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected
                        ? (isBestValue ? Color(hex: "00CEC9") : Color.maxxPrimary)
                        : Color.white.opacity(0.06),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .overlay(alignment: .topTrailing) {
                if isBestValue {
                    Text("POPULAR")
                        .font(.system(size: 8, weight: .heavy))
                        .foregroundColor(.maxxBackground)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "00CEC9"))
                        .clipShape(Capsule())
                        .offset(x: -8, y: -8)
                }
            }
        }
    }

    // Fallback card when offerings haven't loaded
    private func staticPackageCard(_ pid: SubscriptionManager.ProductID) -> some View {
        let isSelected = (pid == .monthly) // default selected
        let isBestValue = (pid == .monthly)

        return HStack(spacing: 0) {
            ZStack {
                Circle()
                    .stroke(isSelected ? Color(hex: "00CEC9") : Color.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 22, height: 22)
                if isSelected {
                    Circle().fill(Color(hex: "00CEC9")).frame(width: 14, height: 14)
                }
            }
            .padding(.trailing, 14)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(pid.displayName)
                        .font(.body).fontWeight(.semibold).foregroundColor(.white)
                    if let badge = pid.badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(.maxxBackground)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(isBestValue ? Color(hex: "00CEC9") : Color(hex: "FDCB6E"))
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            Text(subManager.fallbackPrice(for: pid))
                .font(.body).fontWeight(.bold).foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isSelected ? Color(hex: "00CEC9").opacity(0.1) : Color.maxxSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? Color(hex: "00CEC9") : Color.white.opacity(0.06), lineWidth: isSelected ? 2 : 1)
        )
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button {
            guard let package = selectedPackage ?? subManager.packages.first(where: { subManager.isMonthly($0) }) else { return }
            isPurchasing = true
            Task {
                let success = await subManager.purchase(package)
                isPurchasing = false
                if success {
                    showCelebration = true
                    try? await Task.sleep(for: .seconds(2.5))
                    onContinue()
                }
            }
        } label: {
            HStack(spacing: 10) {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "sparkles")
                        .font(.headline)

                    Text("Start My Free Trial")
                        .font(.headline)
                        .fontWeight(.heavy)
                }
            }
            .foregroundColor(Color(hex: "0A0A0F"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color(hex: "00CEC9"), Color(hex: "6C5CE7")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color(hex: "00CEC9").opacity(0.4), radius: 16, y: 6)
        }
        .disabled(isPurchasing)
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    // MARK: - Trial Disclaimer

    private var trialDisclaimer: some View {
        VStack(spacing: 6) {
            if let package = selectedPackage {
                Text("3-day free trial, then \(package.localizedPriceString)\(periodLabel(package))")
                    .font(.caption)
                    .foregroundColor(.maxxTextSecondary)
            } else {
                Text("3-day free trial, then $9.99/mo")
                    .font(.caption)
                    .foregroundColor(.maxxTextSecondary)
            }

            Text("Cancel anytime in Settings. No charge during trial.")
                .font(.caption2)
                .foregroundColor(.maxxTextMuted)

            if let error = subManager.errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(.maxxError)
                    .padding(.top, 4)
            }
        }
        .padding(.top, 12)
        .padding(.horizontal, 24)
        .multilineTextAlignment(.center)
    }

    // MARK: - Skip

    private var skipButton: some View {
        Button {
            onContinue()
        } label: {
            Text("Continue with limited version")
                .font(.subheadline)
                .foregroundColor(.maxxTextMuted)
                .underline()
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Legal Footer

    private var legalFooter: some View {
        VStack(spacing: 8) {
            HStack(spacing: 20) {
                Button("Terms of Use") { }
                    .font(.caption2).foregroundColor(.maxxTextMuted)

                Button("Privacy Policy") { }
                    .font(.caption2).foregroundColor(.maxxTextMuted)

                Button("Restore Purchases") {
                    Task { await subManager.restorePurchases() }
                }
                .font(.caption2).foregroundColor(.maxxTextMuted)
            }

            Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.")
                .font(.system(size: 9))
                .foregroundColor(.maxxTextMuted.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.bottom, 24)
    }

    // MARK: - Celebration Overlay

    private var celebrationOverlay: some View {
        VStack(spacing: 28) {
            Spacer()

            // Neon glow ring around logo
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "6C5CE7"), Color(hex: "00CEC9"), Color(hex: "FDCB6E")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 160, height: 160)
                    .shadow(color: Color(hex: "00CEC9").opacity(0.6), radius: 30)

                Image("MaxxLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
            .scaleEffect(showCelebration ? 1 : 0.3)
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showCelebration)

            VStack(spacing: 8) {
                Text("Welcome to Maxx Pro!")
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "6C5CE7"), Color(hex: "00CEC9"), Color(hex: "FDCB6E")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Your full glow-up journey starts now")
                    .font(.subheadline)
                    .foregroundColor(.maxxTextSecondary)
            }
            .opacity(showCelebration ? 1 : 0)
            .offset(y: showCelebration ? 0 : 20)
            .animation(.spring(response: 0.6).delay(0.3), value: showCelebration)

            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "FDCB6E"), Color(hex: "F0932B")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(showCelebration ? 1 : 0)
                .scaleEffect(showCelebration ? 1 : 0.5)
                .animation(.spring(response: 0.5).delay(0.5), value: showCelebration)

            Spacer()
        }
        .transition(.opacity)
    }

    // MARK: - Helpers

    private func selectDefaultPackage() {
        guard selectedPackage == nil, !subManager.packages.isEmpty else { return }
        selectedPackage = subManager.packages.first(where: { subManager.isMonthly($0) })
            ?? subManager.packages.first
    }

    private func periodLabel(_ package: Package) -> String {
        switch package.packageType {
        case .weekly: "/wk"
        case .monthly: "/mo"
        case .annual: "/yr"
        case .lifetime: ""
        default: ""
        }
    }
}
