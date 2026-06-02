import SwiftUI
import RevenueCat

// MARK: - PaywallView

struct PaywallView: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @Environment(\.openURL) private var openURL
    @State private var subManager  = SubscriptionManager.shared
    @State private var animate      = false
    @State private var selectedPID: SubscriptionManager.ProductID = .yearly
    @State private var selectedLive: Package?
    @State private var isPurchasing = false
    @State private var showCelebration = false
    @State private var showSkipButton = false

    // Live packages keyed by ProductID for O(1) lookup
    private var liveMap: [SubscriptionManager.ProductID: Package] {
        Dictionary(uniqueKeysWithValues:
            subManager.packages.compactMap { pkg in
                guard let pid = subManager.productID(for: pkg) else { return nil }
                return (pid, pkg)
            }
        )
    }

    private var useLive: Bool { !subManager.packages.isEmpty }

    var body: some View {
        ZStack {
            // Deep background — canonical brand color
            Color.maxxBackground.ignoresSafeArea()

            // Ambient radial glow
            RadialGradient(
                colors: [Color.maxxPrimary.opacity(0.20), .clear],
                center: .top, startRadius: 0, endRadius: 420
            )
            .ignoresSafeArea()

            if showCelebration {
                celebrationOverlay
            } else {
                VStack(spacing: 0) {
                    dismissButton
                    mainContent
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.82)) { animate = true }
            Task { await subManager.fetchOfferings() }

            // Delay "Continue free" to reduce skip rate
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeIn(duration: 0.4)) {
                    showSkipButton = true
                }
            }
        }
        .onChange(of: subManager.packages) { _, _ in syncSelection() }
    }

    // MARK: - Layout

    private var mainContent: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    hero
                    benefitList
                    planCards
                }
                .padding(.bottom, 8)
            }
            // Sticky CTA so it's always visible regardless of device height
            ctaSection
            footerLinks
        }
        .padding(.bottom, 10)
    }

    // MARK: - Dismiss

    private var dismissButton: some View {
        HStack {
            Spacer()
            if showSkipButton {
                Button { onContinue() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.35))
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.06))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Dismiss paywall")
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 4)
        .frame(minHeight: 38)
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [Color.maxxPrimary.opacity(0.45), .clear],
                        center: .center, startRadius: 2, endRadius: 64
                    ))
                    .frame(width: 128, height: 128)

                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(LinearGradient(
                            colors: [Color.maxxPrimary, Color.maxxCyan],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 72, height: 72)
                        .shadow(color: Color.maxxPrimary.opacity(0.6), radius: 18, y: 6)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text("Maxx Pro")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(LinearGradient(
                        colors: [.white, Color.maxxCyan],
                        startPoint: .leading, endPoint: .trailing
                    ))
                Text("Unlock your full glow-up")
                    .font(.subheadline)
                    .foregroundColor(.maxxTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
        .padding(.bottom, 12)
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 10)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.05), value: animate)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Benefit list ("everything in Pro")

    private var benefitList: some View {
        VStack(alignment: .leading, spacing: 9) {
            benefitRow("infinity", "Unlimited routines & progress photos")
            benefitRow("rectangle.on.rectangle.angled", "Side-by-side compare & Mirror Mode")
            benefitRow("flame.fill", "Daily quests, badges & XP")
            benefitRow("chart.line.uptrend.xyaxis", "Glow analytics & trends")
            benefitRow("lock.open.fill", "Every future Pro feature")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 26)
        .padding(.bottom, 14)
        .opacity(animate ? 1 : 0)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.12), value: animate)
    }

    private func benefitRow(_ icon: String, _ text: LocalizedStringKey) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.maxxCyan.opacity(0.14))
                    .frame(width: 26, height: 26)
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.maxxCyan)
            }
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer(minLength: 0)
        }
    }

    // MARK: - Plan Cards

    private var planCards: some View {
        VStack(spacing: 9) {
            ForEach(SubscriptionManager.ProductID.allCases, id: \.self) { pid in
                planCard(pid)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 12)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                        .delay(0.15 + Double(pid.sortOrder) * 0.055),
                        value: animate
                    )
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
    }

    @ViewBuilder
    private func planCard(_ pid: SubscriptionManager.ProductID) -> some View {
        let isSelected  = selectedPID == pid
        let featured    = pid == .yearly
        let pkg         = liveMap[pid]

        // Pricing strings
        let price       = pkg?.localizedPriceString ?? subManager.fallbackPrice(for: pid)
        let period      = pkg.map { subManager.periodLabel($0) } ?? subManager.fallbackPeriod(for: pid)
        let hasTrial    = pkg.map { subManager.hasTrial($0) } ?? pid.hasTrial
        let weeklyEq    = pkg.flatMap { subManager.weeklyEquivalent(for: $0) }
        let savingsPct  = pid == .yearly
            ? subManager.yearlySavingsPercent(yearlyPackage: pkg ?? liveMap[.yearly], monthlyPackage: liveMap[.monthly])
            : 0

        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                selectedPID = pid
                selectedLive = liveMap[pid]
            }
            HapticService.selection()
        } label: {
            HStack(spacing: 12) {
                // Selection ring
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.maxxPrimary : Color.white.opacity(0.22), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle().fill(Color.maxxPrimary).frame(width: 12, height: 12)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.25), value: isSelected)

                // Plan info
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(pid.displayName)
                            .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                        if pid == .yearly && savingsPct > 0 {
                            planBadge("SAVE \(savingsPct)%",
                                      fill: AnyShapeStyle(LinearGradient(colors: [.maxxGold, Color(hex: "FF8C00")],
                                                          startPoint: .leading, endPoint: .trailing)))
                        } else if pid == .monthly {
                            planBadge("POPULAR", fill: AnyShapeStyle(Color.maxxCyan))
                        }
                    }
                    Text(planSubtitle(pid, hasTrial: hasTrial))
                        .font(.caption2)
                        .foregroundColor(featured ? .maxxCyan : .maxxTextSecondary)
                }

                Spacer(minLength: 8)

                // Price column
                VStack(alignment: .trailing, spacing: 1) {
                    HStack(alignment: .lastTextBaseline, spacing: 1) {
                        Text(price).font(.system(size: 17, weight: .bold)).foregroundColor(.white)
                        if !period.isEmpty {
                            Text(period).font(.caption2).foregroundColor(.maxxTextSecondary)
                        }
                    }
                    if let eq = weeklyEq {
                        Text(eq).font(.system(size: 9)).foregroundColor(.maxxTextMuted)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.maxxPrimary.opacity(0.16) : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                isSelected
                                ? AnyShapeStyle(LinearGradient(colors: [Color.maxxPrimary, Color.maxxCyan],
                                                               startPoint: .leading, endPoint: .trailing))
                                : AnyShapeStyle(Color.white.opacity(featured ? 0.18 : 0.08)),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel(for: pid, price: price, period: period, hasTrial: hasTrial))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func planBadge(_ text: String, fill: AnyShapeStyle) -> some View {
        Text(text)
            .font(.system(size: 8, weight: .heavy))
            .foregroundColor(.maxxBackground)
            .padding(.horizontal, 6).padding(.vertical, 2.5)
            .background(fill)
            .clipShape(Capsule())
    }

    private func planSubtitle(_ pid: SubscriptionManager.ProductID, hasTrial: Bool) -> LocalizedStringKey {
        switch pid {
        case .weekly:   return "Billed weekly"
        case .monthly:  return hasTrial ? "3-day free trial included" : "Billed monthly"
        case .yearly:   return hasTrial ? "Best value · 3-day free trial" : "Best value · billed yearly"
        case .lifetime: return "Pay once · yours forever"
        }
    }

    private func accessibilityLabel(
        for pid: SubscriptionManager.ProductID,
        price: String,
        period: String,
        hasTrial: Bool
    ) -> String {
        var parts = [pid.displayName, "\(price)\(period)"]
        if hasTrial { parts.append("3-day free trial included") }
        if pid == .monthly { parts.append("Best value") }
        if pid == .yearly  { parts.append("Save 58 percent") }
        return parts.joined(separator: ", ")
    }

    // MARK: - CTA Section

    private var ctaSection: some View {
        VStack(spacing: 10) {
            // Primary CTA
            Button {
                Task { await handlePurchase() }
            } label: {
                HStack(spacing: 8) {
                    if isPurchasing {
                        ProgressView().tint(.white).scaleEffect(0.85)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .bold))
                        Text(ctaLabel)
                            .font(.headline).fontWeight(.heavy)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    LinearGradient(
                        colors: [Color.maxxPrimary, Color(hex: "6B0FD4")],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color.maxxPrimary.opacity(0.50), radius: 16, y: 6)
            }
            .disabled(isPurchasing)
            .opacity(animate ? 1 : 0)
            .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.38), value: animate)
            .accessibilityLabel(ctaLabel)
            .accessibilityHint("Double tap to start your subscription")

            // Subtitle below CTA
            Text(ctaSubtitle)
                .font(.caption)
                .foregroundColor(.maxxTextSecondary)
                .multilineTextAlignment(.center)
                .opacity(animate ? 1 : 0)
                .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.42), value: animate)

            if let err = subManager.errorMessage {
                Text(err)
                    .font(.caption2).foregroundColor(Color(hex: "FF6B6B"))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
    }

    private var ctaLabel: String {
        if selectedPID.hasTrial { return "Start Free Trial" }
        return "Get \(selectedPID.displayName)"
    }

    private var ctaSubtitle: String {
        let price = liveMap[selectedPID]?.localizedPriceString ?? subManager.fallbackPrice(for: selectedPID)
        let period = liveMap[selectedPID].map { subManager.periodLabel($0) } ?? subManager.fallbackPeriod(for: selectedPID)
        if selectedPID.hasTrial {
            return "3 days free, then \(price)\(period). Auto-renews until canceled; cancel anytime in Settings."
        }
        if selectedPID == .lifetime {
            return "One-time purchase · no subscription"
        }
        return "\(price)\(period). Auto-renews until canceled; cancel anytime in Settings."
    }

    // MARK: - Footer Links

    private var footerLinks: some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                Spacer()
                Button("Restore") { Task { await subManager.restorePurchases() } }
                Text(" · ").foregroundColor(.maxxTextMuted)
                Button("Terms") { openURL(URL(string: "https://gwlabs.app/terms")!) }
                Text(" · ").foregroundColor(.maxxTextMuted)
                Button("Privacy") { openURL(URL(string: "https://gwlabs.app/privacy")!) }
                Spacer()
            }
            .font(.system(size: 11))
            .foregroundColor(.maxxTextMuted)

            if showSkipButton {
                Button("Continue with limited features") { onContinue() }
                    .font(.system(size: 11))
                    .foregroundColor(.maxxTextMuted.opacity(0.6))
                    .transition(.opacity)
            }
        }
        .padding(.top, 10)
        .opacity(animate ? 1 : 0)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.46), value: animate)
    }

    // MARK: - Celebration Overlay

    private var celebrationOverlay: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.maxxPrimary, Color.maxxCyan, Color.maxxGold],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 3.5
                    )
                    .frame(width: 156, height: 156)
                    .shadow(color: Color.maxxCyan.opacity(0.55), radius: 28)

                Image("MaxxLogo")
                    .resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 116, height: 116)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            }
            .scaleEffect(showCelebration ? 1 : 0.25)
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showCelebration)
            .accessibilityHidden(true)

            VStack(spacing: 6) {
                Text("Welcome to Maxx Pro!")
                    .font(.title2).fontWeight(.black)
                    .foregroundStyle(LinearGradient(
                        colors: [Color.maxxPrimary, Color.maxxCyan, Color.maxxGold],
                        startPoint: .leading, endPoint: .trailing
                    ))
                Text("Your full glow-up journey starts now")
                    .font(.subheadline).foregroundColor(.maxxTextSecondary)
            }
            .opacity(showCelebration ? 1 : 0)
            .offset(y: showCelebration ? 0 : 18)
            .animation(.spring(response: 0.6).delay(0.3), value: showCelebration)
            .accessibilityElement(children: .combine)

            Image(systemName: "crown.fill")
                .font(.system(size: 46))
                .foregroundStyle(LinearGradient(
                    colors: [Color.maxxGold, Color(hex: "FF8C00")],
                    startPoint: .top, endPoint: .bottom
                ))
                .opacity(showCelebration ? 1 : 0)
                .scaleEffect(showCelebration ? 1 : 0.4)
                .animation(.spring(response: 0.5).delay(0.5), value: showCelebration)
                .accessibilityHidden(true)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.maxxBackground.ignoresSafeArea())
        .transition(.opacity)
    }

    // MARK: - Purchase Handler

    @MainActor
    private func handlePurchase() async {
        let package: Package? = liveMap[selectedPID]
        guard let pkg = package else {
            // No live packages yet — re-fetch then try
            await subManager.fetchOfferings()
            guard let retry = liveMap[selectedPID] else {
                subManager.errorMessage = "Plans unavailable. Check your connection."
                return
            }
            await doPurchase(retry)
            return
        }
        await doPurchase(pkg)
    }

    @MainActor
    private func doPurchase(_ pkg: Package) async {
        isPurchasing = true
        let success = await subManager.purchase(pkg)
        isPurchasing = false
        if success {
            showCelebration = true
            try? await Task.sleep(for: .seconds(2.5))
            onContinue()
        }
    }

    // MARK: - Helpers

    private func syncSelection() {
        // Keep selection in sync when live packages arrive
        if liveMap[selectedPID] != nil { return }
        if let monthly = liveMap[.monthly] {
            selectedLive = monthly
        }
    }
}
