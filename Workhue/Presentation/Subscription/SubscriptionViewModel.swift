//
//  SubscriptionViewModel.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation
import Combine


@MainActor
final class SubscriptionViewModel: ObservableObject {

    @Published var isLoading: Bool = false

    // MARK: - 복원
    func restore() {
        Task {
            isLoading = true
            // TODO: StoreKit 2 복원 로직 연결
            print("구독 복원 시도")
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isLoading = false
        }
    }
    
    func purchaseMonthly() {
        Task {
            isLoading = true
            // TODO: StoreKit 2 연결
            isLoading = false
        }
    }

    func purchaseYearly() {
        Task {
            isLoading = true
            // TODO: StoreKit 2 연결
            isLoading = false
        }
    }
}
