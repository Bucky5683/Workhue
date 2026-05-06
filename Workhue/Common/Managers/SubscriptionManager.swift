//
//  SubscriptionManager.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import Foundation
import StoreKit
import Combine

@MainActor
final class SubscriptionManager: ObservableObject {

    static let shared = SubscriptionManager()

    private let iCloudEnabledKey = "setting.iCloudEnabled"

    static let monthlyID = "workhue.premium.monthly"
    static let yearlyID  = "workhue.premium.yearly"

    @Published private(set) var isSubscribed: Bool = false
    @Published private(set) var products: [Product] = []

    var useICloud: Bool {
        isSubscribed && isICloudEnabled
    }

    var isICloudEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: iCloudEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: iCloudEnabledKey) }
    }

    private init() {}

    // MARK: - 상품 로드
    func loadProducts() async {
        do {
            products = try await Product.products(for: [
                Self.monthlyID,
                Self.yearlyID
            ])
        } catch {
            print("상품 로드 실패: \(error)")
        }
    }

    // MARK: - 구매
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus()
            await transaction.finish()
            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - 복원
    func restorePurchases() async {
        try? await AppStore.sync()
        await updateSubscriptionStatus()
    }

    // MARK: - 구독 상태 갱신
    func updateSubscriptionStatus() async {
        var subscribed = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == Self.monthlyID ||
                   transaction.productID == Self.yearlyID {
                    subscribed = !transaction.isUpgraded
                }
            }
        }

        isSubscribed = subscribed
    }

    // MARK: - Transaction.updates listener
    func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction 검증 실패: \(error)")
                }
            }
        }
    }

    // MARK: - 검증
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let value):
            return value
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
