//
//  SubscriptionManager.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import Foundation
import Combine

final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    private init() {
        isSubscribed = UserDefaults.standard.bool(forKey: "isSubscribed")
    }

    @Published private(set) var isSubscribed: Bool = false {
        didSet {
            UserDefaults.standard.set(isSubscribed, forKey: "isSubscribed")
        }
    }

    // 나중에 StoreKit 2로 교체할 메서드들

    // 구독 상태 확인 (StoreKit 연동 시 실제 영수증 검증으로 교체)
    func checkSubscriptionStatus() {
        isSubscribed = UserDefaults.standard.bool(forKey: "isSubscribed")
    }

    // 구독 화면에서 구독 완료 시 호출 (StoreKit 연동 시 실제 결제 로직으로 교체)
    func purchase() {
        isSubscribed = true
    }

    // 구독 복원 (StoreKit 연동 시 실제 복원 로직으로 교체)
    func restore() {
        isSubscribed = UserDefaults.standard.bool(forKey: "isSubscribed")
    }

    // 구독 해지 시 호출 (StoreKit 연동 시 제거)
    func cancel() {
        isSubscribed = false
    }
}
