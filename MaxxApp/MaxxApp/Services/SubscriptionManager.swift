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

    /// True when the user has an active "pro" entitlement
    var isPremium: Bool = false

    /// Current offering packages fetched from RevenueCat
    var packages: [Package] = []

    /// Loading state for offerings fetch
    var isLoadingOfferings: Bool = false

    /// Error message for UI display
    var errorMessage: String?

    /// Shows the celebration overlay after a successful purchase
    var showCelebration: Bool = false

    /// Set after a purchase completes so the paywall can dismiss
    var purchaseCompleted: Bool = false

    // MARK: - Constants

    /// The entitlement identifier configured in the RevenueCat dashboard
    static let entitlementID = "pro"

    /// Product identifiers expected in App Store Connect
    enum ProductID: String, CaseIterable {
        case weekly   = "com.clawdbonzo.MaxxApp.weekly"
        case monthly  = "com.clawdbonzo.MaxxApp.monthly"
        case yearly   = "com.clawdbonzo.MaxxApp.yearly"
        case lifetime = "com.clawdbonzo.MaxxApp.lifetime"

        var displayName: String {
            switch self {
            case .weekly:   "Weekly"
            case .monthly:  "Monthly"
            case .yearly:   "Yearly"
            case .lifetime: "Lifetime"
            }
        }

        var badge: String? {
            switch self {
            case .monthly: "BEST VALUE"
            case .yearly: "58% OFF"
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

    private override init() {
        super.init()
    }

    /// Call once from MaxxApp.init() after Purchases.configure()
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
                // Sort: weekly → monthly → yearly → lifetime
                packages = current.availablePackages.sorted { a, b in
                    packageSortOrder(a) < packageSortOrder(b)
                }
            }
        } catch {
            errorMessage = "Unable to load plans. Pull down to retry."
            print("[SubscriptionManager] Offerings error: \(error)")
        }

        isLoadingOfferings = false
    }

    // MARK: - Purchase

    func purchase(_ package: Package) async -> Bool {
        errorMessage = nil
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if result.userCancelled {
                return false
            }
            // entitlement will be updated via delegate
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

    /// Fallback prices when RevenueCat hasn't loaded yet (shown as placeholders)
    func fallbackPrice(for productID: ProductID) -> String {
        switch productID {
        case .weekly:   "$4.99/wk"
        case .monthly:  "$9.99/mo"
        case .yearly:   "$49.99/yr"
        case .lifetime: "$79.99"
        }
    }

    func weeklyEquivalent(for package: Package) -> String? {
        let price = package.storeProduct.price as Decimal
        switch package.packageType {
        case .monthly:
            let weekly = price / 4
            return "$\(NSDecimalNumber(decimal: weekly).rounding(accordingToBehavior: roundingBehavior).stringValue)/wk"
        case .annual:
            let weekly = price / 52
            return "$\(NSDecimalNumber(decimal: weekly).rounding(accordingToBehavior: roundingBehavior).stringValue)/wk"
        default:
            return nil
        }
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

    func productID(for package: Package) -> ProductID? {
        ProductID(rawValue: package.storeProduct.productIdentifier)
    }

    private func packageSortOrder(_ package: Package) -> Int {
        if let pid = productID(for: package) {
            return pid.sortOrder
        }
        switch package.packageType {
        case .weekly: return 0
        case .monthly: return 1
        case .annual: return 2
        case .lifetime: return 3
        default: return 99
        }
    }

    func isMonthly(_ package: Package) -> Bool {
        package.packageType == .monthly ||
        package.storeProduct.productIdentifier.contains("monthly")
    }
}

// MARK: - PurchasesDelegate

extension SubscriptionManager: PurchasesDelegate {
    nonisolated func purchases(
        _ purchases: Purchases,
        receivedUpdated customerInfo: CustomerInfo
    ) {
        let isActive = customerInfo.entitlements[SubscriptionManager.entitlementID]?.isActive ?? false
        Task { @MainActor in
            self.isPremium = isActive
        }
    }
}
