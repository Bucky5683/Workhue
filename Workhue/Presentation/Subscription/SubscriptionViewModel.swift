//
//  SubscriptionViewModel.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation
import StoreKit
import Combine

@MainActor
final class SubscriptionViewModel: ObservableObject {

    @Published var isLoading: Bool = false

    private let manager = SubscriptionManager.shared

    var products: [Product] { manager.products }

    func purchaseMonthly() {
        guard let product = manager.products.first(where: {
            $0.id == SubscriptionManager.monthlyID
        }) else {
            showError("상품 정보를 불러올 수 없어요.")
            return
        }
        purchase(product)
    }

    func purchaseYearly() {
        guard let product = manager.products.first(where: {
            $0.id == SubscriptionManager.yearlyID
        }) else {
            showError("상품 정보를 불러올 수 없어요.")
            return
        }
        purchase(product)
    }

    private func purchase(_ product: Product) {
        Task {
            isLoading = true
            do {
                _ = try await manager.purchase(product)
            } catch {
                showError("결제 중 오류가 발생했어요. 다시 시도해주세요.")
            }
            isLoading = false
        }
    }

    func restore() {
        Task {
            isLoading = true
            await manager.restorePurchases()
            if !manager.isSubscribed {
                showError("복원할 구독 내역이 없어요.")
            }
            isLoading = false
        }
    }

    private func showError(_ message: String) {
        NavigationRouter.shared.showAlert(
            AlertModel(
                title: "안내",
                message: message,
                cancelTitle: "",
                confirmTitle: "확인"
            )
        )
    }
}
