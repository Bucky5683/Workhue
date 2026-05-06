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
    private var didEarnReward = false

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

        didEarnReward = false

        return await withCheckedContinuation { continuation in
            adContinuation = continuation
            ad.present(from: rootVC) { [weak self] in
                Task { @MainActor in
                    self?.didEarnReward = true
                }
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
            adContinuation?.resume(returning: didEarnReward)
            adContinuation = nil
            didEarnReward = false
            rewardedAd = nil
            isAdReady = false
            loadAd()
        }
    }

    // 광고 표시 실패
    nonisolated func ad(
        _ ad: FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        Task { @MainActor in
            print("광고 표시 실패: \(error.localizedDescription)")
            adContinuation?.resume(returning: false)
            adContinuation = nil
            didEarnReward = false
            rewardedAd = nil
            isAdReady = false
            loadAd()
        }
    }
}
