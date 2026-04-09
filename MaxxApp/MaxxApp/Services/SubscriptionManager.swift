import Foundation
import RevenueCat
import SwiftUI

/// Central subscription manager — single source of truth for premium state.
/// Listens to RevenueCat CustomerInfo and publishes changes via @Observable.
@Observable
@MainActor
final class SubscriptionManager: NSObject {
    static let shared = SubscriptionManager()

    // MARK: - Published State

    var isPremium: Bool = false
    var packages: [Package] = []
    var isLoadingOfferings: Bool = false
    var errorMessage: String?
    var showCelebration: Bool = false
    var purchaseCompleted: Bool = false

    // MARK: - Constants

    static let entitlementID = "pro"

    /// Canonical product identifiers — must match App Store Connect exactly
    enum ProductID: String, CaseIterable {
        case weekly   = "com.clawdbonzo.maxx.weekly"
        case monthly  = "com.clawdbonzo.maxx.monthly"
        case yearly   = "com.clawdbonzo.maxx.yearly"
        case lifetime = "com.clawdbonzo.maxx.lifetime"

        var displayName: String {
            switch self {
            case .weekly:   "Weekly"
            case .monthly:  "Monthly"
            case .yearly:   "Yearly"
            case .lifetime: "Lifetime"
            }
        }

        /// Badge shown inside the plan card
        var badge: String? {
            switch self {
            case .monthly: "BEST VALUE"
            default: nil
            }
        }

        /// Whether this plan includes a 3-day free trial
        var hasTrial: Bool {
            switch self {
            case .monthly, .yearly: true
            case .weekly, .lifetime: false
            }
        }

        /// Yearly savings vs monthly ($9.99 × 12 = $119.88 vs $49.99 → ~58% off)
        var savingsLabel: String? {
            switch self {
            case .yearly: "SAVE 58%"
            default: nil
            }
        }

        var sortOrder: Int {
            switch self {
            case .weekly: 0
            case .monthly: 1
            case .yearly: 2
            case .lifetime: 3
            }
        }
    }

    // MARK: - Init

    private override init() { super.init() }

    func start() {
        Purchases.shared.delegate = self
        Task { await checkEntitlements() }
        Task { await fetchOfferings() }
    }

    // MARK: - Offerings

    func fetchOfferings() async {
        isLoadingOfferings = true
        errorMessage = nil
        do {
            let offerings = try await Purchases.shared.offerings()
            if let current = offerings.current {
                packages = current.availablePackages.sorted {
                    packageSortOrder($0) < packageSortOrder($1)
                }
            }
        } catch {
            errorMessage = "Unable to load plans. Tap to retry."
            print("[SubscriptionManager] Offerings error: \(error)")
        }
        isLoadingOfferings = false
    }

    // MARK: - Purchase

    func purchase(_ package: Package) async -> Bool {
        errorMessage = nil
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if result.userCancelled { return false }
            purchaseCompleted = true
            showCelebration = true
            HapticService.success()
            return true
        } catch {
            errorMessage = error.localizedDescription
            HapticService.error()
            return false
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        errorMessage = nil
        do {
            let info = try await Purchases.shared.restorePurchases()
            isPremium = info.entitlements[Self.entitlementID]?.isActive ?? false
            if isPremium {
                purchaseCompleted = true
                HapticService.success()
            } else {
                errorMessage = "No active subscription found."
            }
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Entitlement Check

    func checkEntitlements() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            isPremium = info.entitlements[Self.entitlementID]?.isActive ?? false
        } catch {
            print("[SubscriptionManager] Entitlement check error: \(error)")
        }
    }

    // MARK: - Helpers

    /// Fallback prices shown while RevenueCat loads (accurate to spec)
    func fallbackPrice(for productID: ProductID) -> String {
        switch productID {
        case .weekly:   "$4.99"
        case .monthly:  "$9.99"
        case .yearly:   "$49.99"
        case .lifetime: "$79.99"
        }
    }

    func fallbackPeriod(for productID: ProductID) -> String {
        switch productID {
        case .weekly:   "/wk"
        case .monthly:  "/mo"
        case .yearly:   "/yr"
        case .lifetime: ""
        }
    }

    /// Per-week equivalent for multi-period plans
    func weeklyEquivalent(for package: Package) -> String? {
        let price = package.storeProduct.price as Decimal
        switch package.packageType {
        case .monthly:
            let weekly = price / 4
            return "$\(roundedString(weekly))/wk"
        case .annual:
            let weekly = price / 52
            return "$\(roundedString(weekly))/wk"
        default:
            return nil
        }
    }

    /// Actual savings percentage vs monthly for yearly plan
    func yearlySavingsPercent(yearlyPackage: Package, monthlyPackage: Package?) -> Int {
        let yearlyPrice = yearlyPackage.storeProduct.price as Decimal
        if let monthly = monthlyPackage {
            let monthlyPrice = monthly.storeProduct.price as Decimal
            let fullYear = monthlyPrice * 12
            guard fullYear > 0 else { return 58 }
            let saving = (fullYear - yearlyPrice) / fullYear * 100
            return Int(NSDecimalNumber(decimal: saving).rounding(accordingToBehavior: roundingBehavior).intValue)
        }
        // Fallback: $9.99×12=$119.88 vs $49.99 = 58%
        return 58
    }

    /// Whether the live package has a free trial configured in RC
    func hasTrial(_ package: Package) -> Bool {
        if let pid = productID(for: package) { return pid.hasTrial }
        // Fallback by type
        return package.packageType == .monthly || package.packageType == .annual
    }

    func productID(for package: Package) -> ProductID? {
        ProductID(rawValue: package.storeProduct.productIdentifier)
    }

    func isMonthly(_ package: Package) -> Bool {
        package.packageType == .monthly ||
        package.storeProduct.productIdentifier.contains("monthly")
    }

    func isBestValue(_ package: Package) -> Bool {
        isMonthly(package)
    }

    func periodLabel(_ package: Package) -> String {
        switch package.packageType {
        case .weekly:  "/wk"
        case .monthly: "/mo"
        case .annual:  "/yr"
        default: ""
        }
    }

    // MARK: - Private

    private func packageSortOrder(_ package: Package) -> Int {
        if let pid = productID(for: package) { return pid.sortOrder }
        switch package.packageType {
        case .weekly:   return 0
        case .monthly:  return 1
        case .annual:   return 2
        case .lifetime: return 3
        default:        return 99
        }
    }

    private func roundedString(_ value: Decimal) -> String {
        NSDecimalNumber(decimal: value)
            .rounding(accordingToBehavior: roundingBehavior)
            .stringValue
    }

    private var roundingBehavior: NSDecimalNumberHandler {
        NSDecimalNumberHandler(
            roundingMode: .plain,
            scale: 2,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
    }
}

// MARK: - PurchasesDelegate

extension SubscriptionManager: PurchasesDelegate {
    nonisolated func purchases(
        _ purchases: Purchases,
        receivedUpdated customerInfo: CustomerInfo
    ) {
        let isActive = customerInfo.entitlements[SubscriptionManager.entitlementID]?.isActive ?? false
        Task { @MainActor in self.isPremium = isActive }
    }
}
