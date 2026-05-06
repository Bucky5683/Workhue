//
//  RewardedAdManager.swift
//  Workhue
//
//  Created by 김서연 on 5/6/26.
//

import GoogleMobileAds
import UIKit
import Combine

@MainActor
final class RewardedAdManager: NSObject, ObservableObject {

    static let shared = RewardedAdManager()

    // 출시 전 실제 광고 단위 ID로 교체
    private let adUnitID: String = {
        #if DEBUG
        return "ca-app-pub-3940256099942544/1712485313"  // 테스트 ID
        #else
        guard let id = Bundle.main.object(forInfoDictionaryKey: "GADRewardedAdUnitID") as? String else {
            fatalError("GADRewardedAdUnitID not found in Config.plist")
        }
        return id
        #endif
    }()

    @Published private(set) var isAdReady: Bool = false
    @Published private(set) var isLoading: Bool = false

    private var rewardedAd: RewardedAd?

    private override init() {
        super.init()
    }

    // MARK: - 광고 로드
    func loadAd() {
        guard !isLoading else { return }
        isLoading = true

        let request = Request()
        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isLoading = false

                if let error {
                    print("광고 로드 실패: \(error.localizedDescription)")
                    self.isAdReady = false
                    return
                }

                self.rewardedAd = ad
                self.isAdReady = true
            }
        }
    }

    // MARK: - 광고 표시
    func showAd() async -> Bool {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                guard let ad = rewardedAd,
                      let rootVC = currentRootViewController() else {
                    continuation.resume(returning: false)
                    return
                }

                ad.present(from: rootVC) { [weak self] in
                    continuation.resume(returning: true)
                    self?.rewardedAd = nil
                    self?.isAdReady = false
                    self?.loadAd()
                }
            }
        }
    }

    // MARK: - 루트 ViewController 가져오기
    private func currentRootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
