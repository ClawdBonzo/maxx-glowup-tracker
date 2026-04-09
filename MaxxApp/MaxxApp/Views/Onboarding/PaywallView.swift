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
            Color.maxxBackground.ignoresSafeArea()

            if showCelebration {
                celebrationOverlay
            } else {
                VStack(spacing: 0) {
                    closeButton
                    paywallContent
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.8)) {
                animate = true
            }
            Task { await subManager.fetchOfferings() }
            selectDefaultPackage()
        }
        .onChange(of: subManager.packages) { _, _ in
            selectDefaultPackage()
        }
    }

    // MARK: - No-Scroll Paywall Layout

    private var paywallContent: some View {
        VStack(spacing: 0) {
            heroSection
            trialBadge
            headline
            featuresList
            packageCards
            ctaButton
            compactFooter
        }
        .padding(.bottom, 8)
    }

    // MARK: - Close Button

    private var closeButton: some View {
        HStack {
            Spacer()
            Button { onContinue() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.25))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 2)
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(hex: "6C5CE7").opacity(0.25), Color(hex: "00CEC9").opacity(0.15)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(height: 96)
                .blur(radius: 20)

            Image("Onboarding4Paywall")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 96)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "6C5CE7").opacity(0.6), Color(hex: "00CEC9").opacity(0.4)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color(hex: "6C5CE7").opacity(0.35), radius: 14, y: 5)
        }
        .padding(.horizontal, 28)
        .opacity(animate ? 1 : 0)
        .scaleEffect(animate ? 1 : 0.88)
        .animation(.spring(response: 0.65, dampingFraction: 0.75), value: animate)
    }

    // MARK: - Trial Badge

    private var trialBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "gift.fill").font(.footnote)
            Text("3-DAY FREE TRIAL")
                .font(.footnote).fontWeight(.heavy).tracking(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14).padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color(hex: "00B894"))
                .shadow(color: Color(hex: "00B894").opacity(0.45), radius: 8, y: 3)
        )
        .padding(.top, 10)
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 6)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.08), value: animate)
    }

    // MARK: - Headline

    private var headline: some View {
        VStack(spacing: 3) {
            Text("Unlock Your Full")
                .font(.title3).fontWeight(.bold).foregroundColor(.white)
            Text("Glow-Up Transformation")
                .font(.title3).fontWeight(.black)
                .foregroundStyle(LinearGradient(
                    colors: [Color(hex: "6C5CE7"), Color(hex: "00CEC9"), Color(hex: "FDCB6E")],
                    startPoint: .leading, endPoint: .trailing
                ))
        }
        .multilineTextAlignment(.center)
        .padding(.top, 8)
        .opacity(animate ? 1 : 0)
        .scaleEffect(animate ? 1 : 0.94)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.12), value: animate)
    }

    // MARK: - Features (4 rows, compact)

    private var featuresList: some View {
        VStack(spacing: 7) {
            proFeatureRow(icon: "camera.fill",               text: "Unlimited progress photos & comparisons")
            proFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Advanced analytics & glow score insights")
            proFeatureRow(icon: "flame.fill",                text: "Daily quests, XP levels & badges")
            proFeatureRow(icon: "lock.open.fill",            text: "Every future feature, forever")
        }
        .padding(.horizontal, 28)
        .padding(.top, 10)
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 8)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.16), value: animate)
    }

    private func proFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.footnote)
                .foregroundColor(Color(hex: "00CEC9"))
            Text(text)
                .font(.subheadline)
                .foregroundColor(.maxxTextSecondary)
            Spacer()
        }
    }

    // MARK: - Package Cards

    private var packageCards: some View {
        VStack(spacing: 7) {
            if subManager.packages.isEmpty {
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
        .padding(.top, 10)
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 10)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.2), value: animate)
    }

    private func livePackageCard(_ package: Package) -> some View {
        let isSelected = selectedPackage?.identifier == package.identifier
        let isBestValue = subManager.isMonthly(package)
        let pid = subManager.productID(for: package)

        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                selectedPackage = package
            }
            HapticService.selection()
        } label: {
            HStack(spacing: 0) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(hex: "00CEC9") : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    if isSelected {
                        Circle().fill(Color(hex: "00CEC9")).frame(width: 12, height: 12)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3), value: isSelected)
                .padding(.trailing, 12)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(pid?.displayName ?? package.storeProduct.localizedTitle)
                            .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                        if let badge = pid?.badge {
                            Text(badge)
                                .font(.system(size: 8, weight: .heavy))
                                .foregroundColor(.maxxBackground)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(isBestValue ? Color(hex: "00CEC9") : Color(hex: "FDCB6E"))
                                .clipShape(Capsule())
                        }
                    }
                    if let weeklyEq = subManager.weeklyEquivalent(for: package) {
                        Text("Just \(weeklyEq)").font(.caption2).foregroundColor(.maxxTextMuted)
                    }
                    if package.packageType == .lifetime {
                        Text("Pay once, own forever").font(.caption2).foregroundColor(.maxxTextMuted)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 1) {
                    Text(package.localizedPriceString)
                        .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                    if package.packageType != .lifetime {
                        Text(periodLabel(package)).font(.caption2).foregroundColor(.maxxTextMuted)
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected
                          ? (isBestValue ? Color(hex: "00CEC9").opacity(0.1) : Color.maxxPrimary.opacity(0.1))
                          : Color.maxxSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isSelected ? (isBestValue ? Color(hex: "00CEC9") : Color.maxxPrimary) : Color.white.opacity(0.06),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .overlay(alignment: .topTrailing) {
                if isBestValue {
                    Text("POPULAR")
                        .font(.system(size: 7, weight: .heavy))
                        .foregroundColor(.maxxBackground)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color(hex: "00CEC9")).clipShape(Capsule())
                        .offset(x: -6, y: -6)
                }
            }
        }
    }

    private func staticPackageCard(_ pid: SubscriptionManager.ProductID) -> some View {
        let isSelected = pid == .monthly
        let isBestValue = pid == .monthly

        return HStack(spacing: 0) {
            ZStack {
                Circle().stroke(isSelected ? Color(hex: "00CEC9") : Color.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 20, height: 20)
                if isSelected { Circle().fill(Color(hex: "00CEC9")).frame(width: 12, height: 12) }
            }.padding(.trailing, 12)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(pid.displayName).font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                    if let badge = pid.badge {
                        Text(badge)
                            .font(.system(size: 8, weight: .heavy)).foregroundColor(.maxxBackground)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(isBestValue ? Color(hex: "00CEC9") : Color(hex: "FDCB6E")).clipShape(Capsule())
                    }
                }
            }
            Spacer()
            Text(subManager.fallbackPrice(for: pid))
                .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(isSelected ? Color(hex: "00CEC9").opacity(0.1) : Color.maxxSurface))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(isSelected ? Color(hex: "00CEC9") : Color.white.opacity(0.06), lineWidth: isSelected ? 2 : 1))
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
            HStack(spacing: 8) {
                if isPurchasing {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "sparkles").font(.subheadline)
                    Text("Start My Free Trial").font(.headline).fontWeight(.heavy)
                }
            }
            .foregroundColor(Color(hex: "0A0A0F"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "00CEC9"), Color(hex: "6C5CE7")],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color(hex: "00CEC9").opacity(0.35), radius: 12, y: 4)
        }
        .disabled(isPurchasing)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .opacity(animate ? 1 : 0)
        .scaleEffect(animate ? 1 : 0.96)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.24), value: animate)
    }

    // MARK: - Compact Footer

    private var compactFooter: some View {
        VStack(spacing: 8) {
            Group {
                if let package = selectedPackage {
                    Text("3-day free trial · then \(package.localizedPriceString)\(periodLabel(package)) · Cancel anytime")
                } else {
                    Text("3-day free trial · then $9.99/mo · Cancel anytime")
                }
            }
            .font(.caption)
            .foregroundColor(.maxxTextSecondary)

            HStack(spacing: 14) {
                Button("Continue free") { onContinue() }
                Text("·").foregroundColor(.maxxTextMuted)
                Button("Restore") { Task { await subManager.restorePurchases() } }
                Text("·").foregroundColor(.maxxTextMuted)
                Button("Terms") { }
                Text("·").foregroundColor(.maxxTextMuted)
                Button("Privacy") { }
            }
            .font(.caption)
            .foregroundColor(.maxxTextMuted)

            if let error = subManager.errorMessage {
                Text(error).font(.caption2).foregroundColor(.maxxError)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.top, 8)
        .padding(.horizontal, 20)
        .opacity(animate ? 1 : 0)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.28), value: animate)
    }

    // MARK: - Celebration Overlay

    private var celebrationOverlay: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "6C5CE7"), Color(hex: "00CEC9"), Color(hex: "FDCB6E")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
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
                    .font(.title).fontWeight(.black)
                    .foregroundStyle(LinearGradient(
                        colors: [Color(hex: "6C5CE7"), Color(hex: "00CEC9"), Color(hex: "FDCB6E")],
                        startPoint: .leading, endPoint: .trailing
                    ))
                Text("Your full glow-up journey starts now")
                    .font(.subheadline).foregroundColor(.maxxTextSecondary)
            }
            .opacity(showCelebration ? 1 : 0)
            .offset(y: showCelebration ? 0 : 20)
            .animation(.spring(response: 0.6).delay(0.3), value: showCelebration)

            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(LinearGradient(
                    colors: [Color(hex: "FDCB6E"), Color(hex: "F0932B")],
                    startPoint: .top, endPoint: .bottom
                ))
                .opacity(showCelebration ? 1 : 0)
                .scaleEffect(showCelebration ? 1 : 0.5)
                .animation(.spring(response: 0.5).delay(0.5), value: showCelebration)

            Spacer()
        }
        .background(Color.maxxBackground.ignoresSafeArea())
        .transition(.opacity)
    }

    // MARK: - Helpers

    private func selectDefaultPackage() {
        guard selectedPackage == nil, !subManager.packages.isEmpty else { return }
        selectedPackage = subManager.packages.first(where: { subManager.isMonthly($0) }) ?? subManager.packages.first
    }

    private func periodLabel(_ package: Package) -> String {
        switch package.packageType {
        case .weekly:  "/wk"
        case .monthly: "/mo"
        case .annual:  "/yr"
        default:       ""
        }
    }
}
