//
//  SettingViewModel.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import Foundation
import Combine
import UserNotifications
import UIKit
import SwiftData

@MainActor
final class SettingViewModel: ObservableObject {

    @Published var isSubscribed: Bool = false
    @Published var iCloudOn: Bool = false
    @Published var totalNotiOn: Bool = false
    @Published var gettingWorkNotiOn: Bool = false
    @Published var endWorkNotiOn: Bool = false
    @Published var hasNewUnlock: Bool = false
    @Published var gettingWorkTime: Date = Calendar.current.date(
        bySettingHour: 9, minute: 0, second: 0, of: Date()
    ) ?? Date()
    @Published var endWorkTime: Date = Calendar.current.date(
        bySettingHour: 18, minute: 0, second: 0, of: Date()
    ) ?? Date()
    @Published var notificationDenied: Bool = false

    private let subscriptionManager = SubscriptionManager.shared
    private let notificationManager = NotificationManager.shared
    private let streakRepo: StreakRepositoryImpl
    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()

    private let totalNotiKey       = "totalNotiOn"
    private let gettingWorkNotiKey = "gettingWorkNotiOn"
    private let endWorkNotiKey     = "endWorkNotiOn"
    private let gettingWorkTimeKey = "gettingWorkTime"
    private let endWorkTimeKey     = "endWorkTime"

    var isICloudEnabled: Bool {
        get { SubscriptionManager.shared.isICloudEnabled }
        set { SubscriptionManager.shared.isICloudEnabled = newValue }
    }

    init() {
        self.streakRepo = StreakRepositoryImpl(context: SwiftDataManager.shared.context)
        loadSavedSettings()
        observeSubscription()
    }

    private func loadSavedSettings() {
        isSubscribed = subscriptionManager.isSubscribed
        iCloudOn = subscriptionManager.isICloudEnabled
        totalNotiOn = defaults.bool(forKey: totalNotiKey)
        gettingWorkNotiOn = defaults.bool(forKey: gettingWorkNotiKey)
        endWorkNotiOn = defaults.bool(forKey: endWorkNotiKey)

        if let savedGettingTime = defaults.object(forKey: gettingWorkTimeKey) as? Date {
            gettingWorkTime = savedGettingTime
        }
        if let savedEndTime = defaults.object(forKey: endWorkTimeKey) as? Date {
            endWorkTime = savedEndTime
        }
    }

    private func observeSubscription() {
        subscriptionManager.$isSubscribed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.isSubscribed = value
                if !value { self?.setICloud(false) }
            }
            .store(in: &cancellables)
    }

    func loadHasNewUnlock() {
        Task {
            hasNewUnlock = (try? await streakRepo.hasNewUnlock()) ?? false
        }
    }

    func setICloud(_ value: Bool) {
        iCloudOn = value
        subscriptionManager.isICloudEnabled = value
    }

    func setTotalNoti(_ value: Bool) {
        if !value {
            gettingWorkNotiOn = false
            endWorkNotiOn = false
            notificationManager.removeAllNotifications()
            defaults.set(false, forKey: gettingWorkNotiKey)
            defaults.set(false, forKey: endWorkNotiKey)
            totalNotiOn = false
            defaults.set(false, forKey: totalNotiKey)
            return
        }
        Task { @MainActor in
            let status = await notificationManager.checkAuthorizationStatus()
            switch status {
            case .notDetermined:
                let granted = await notificationManager.requestAuthorization()
                if granted {
                    totalNotiOn = true
                    defaults.set(true, forKey: totalNotiKey)
                } else {
                    totalNotiOn = false
                    showNotificationDeniedAlert()
                }
            case .authorized, .provisional, .ephemeral:
                totalNotiOn = true
                defaults.set(true, forKey: totalNotiKey)
            case .denied:
                totalNotiOn = false
                showNotificationDeniedAlert()
            @unknown default:
                break
            }
        }
    }

    func showNotificationDeniedAlert() {
        NavigationRouter.shared.showAlert(
            AlertModel(
                title: "알림 권한 필요",
                message: "알림을 받으려면 설정에서 알림 권한을 허용해주세요.",
                confirmTitle: "설정으로 이동",
                cancelTitle: "취소",
                confirmAction: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            )
        )
    }

    func setGettingWorkNoti(_ value: Bool) {
        gettingWorkNotiOn = value
        defaults.set(value, forKey: gettingWorkNotiKey)
        if value { notificationManager.scheduleCheckInNotification(at: gettingWorkTime) }
        else { notificationManager.removeCheckInNotification() }
    }

    func setEndWorkNoti(_ value: Bool) {
        endWorkNotiOn = value
        defaults.set(value, forKey: endWorkNotiKey)
        if value { notificationManager.scheduleCheckOutNotification(at: endWorkTime) }
        else { notificationManager.removeCheckOutNotification() }
    }

    func saveGettingWorkTime() {
        defaults.set(gettingWorkTime, forKey: gettingWorkTimeKey)
        if gettingWorkNotiOn { notificationManager.scheduleCheckInNotification(at: gettingWorkTime) }
    }

    func saveEndWorkTime() {
        defaults.set(endWorkTime, forKey: endWorkTimeKey)
        if endWorkNotiOn { notificationManager.scheduleCheckOutNotification(at: endWorkTime) }
    }
}
