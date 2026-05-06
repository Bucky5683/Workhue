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
            showAlert(message: "상품 정보를 불러올 수 없어요.")
            return
        }
        purchase(product)
    }

    func purchaseYearly() {
        guard let product = manager.products.first(where: {
            $0.id == SubscriptionManager.yearlyID
        }) else {
            showAlert(message: "상품 정보를 불러올 수 없어요.")
            return
        }
        purchase(product)
    }

    private func purchase(_ product: Product) {
        Task {
            isLoading = true
            do {
                let outcome = try await manager.purchase(product)
                switch outcome {
                case .success:
                    break
                case .cancelled:
                    break  // 아무 안내 불필요
                case .pending:
                    showAlert(title: "안내", message: "결제가 보류 중이에요. 승인 후 자동으로 처리돼요.")
                }
            } catch {
                showAlert(title: "결제 실패", message: "결제 중 오류가 발생했어요. 다시 시도해주세요.")
            }
            isLoading = false
        }
    }

    func restore() {
        Task {
            isLoading = true
            do {
                try await manager.restorePurchases()
                if !manager.isSubscribed {
                    showAlert(title: "복원 완료", message: "복원할 구독 내역이 없어요.")
                }
            } catch {
                showAlert(title: "복원 실패", message: "네트워크 오류 또는 인증 실패가 발생했어요. 다시 시도해주세요.")
            }
            isLoading = false
        }
    }

    private func showAlert(title: String = "안내", message: String) {
        NavigationRouter.shared.showAlert(
            AlertModel(
                title: title,
                message: message,
                confirmTitle: "확인",
                cancelTitle: ""
            )
        )
    }
}
