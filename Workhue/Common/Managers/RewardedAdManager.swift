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

    #if DEBUG
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"
    #else
    private let adUnitID: String = {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let id = config["GADRewardedAdUnitID"] as? String else {
            fatalError("GADRewardedAdUnitID not found in Config.plist")
        }
        return id
    }()
    #endif

    @Published private(set) var isAdReady: Bool = false
    @Published private(set) var isLoading: Bool = false

    private var rewardedAd: RewardedAd?
    private var adContinuation: CheckedContinuation<Bool, Never>?

    private override init() {
        super.init()
    }

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
                self.rewardedAd?.fullScreenContentDelegate = self
                self.isAdReady = true
            }
        }
    }

    func showAd() async -> Bool {
        guard let ad = rewardedAd,
              let rootVC = currentRootViewController() else {
            return false
        }

        return await withCheckedContinuation { continuation in
            self.adContinuation = continuation
            var didEarnReward = false

            ad.present(from: rootVC) { [weak self] in
                didEarnReward = true
                // resume은 dismiss에서 한 번만 호출
                _ = didEarnReward
                self?.adContinuation?.resume(returning: true)
                self?.adContinuation = nil
                self?.rewardedAd = nil
                self?.isAdReady = false
                self?.loadAd()
            }
        }
    }

    private func currentRootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}

// MARK: - FullScreenContentDelegate
extension RewardedAdManager: FullScreenContentDelegate {

    // 광고 닫힘 (리워드 못 받고 닫은 경우)
    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            self.adContinuation?.resume(returning: false)
            self.adContinuation = nil
            self.rewardedAd = nil
            self.isAdReady = false
            self.loadAd()
        }
    }

    // 광고 표시 실패
    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            print("광고 표시 실패: \(error.localizedDescription)")
            self.adContinuation?.resume(returning: false)
            self.adContinuation = nil
            self.rewardedAd = nil
            self.isAdReady = false
            self.loadAd()
        }
    }
}
