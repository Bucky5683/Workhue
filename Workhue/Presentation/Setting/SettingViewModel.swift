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

@MainActor
final class SettingViewModel: ObservableObject {

    // MARK: - Published
    @Published var isSubscribed: Bool = false
    @Published var iCloudOn: Bool = false
    @Published var totalNotiOn: Bool = false
    @Published var gettingWorkNotiOn: Bool = false
    @Published var endWorkNotiOn: Bool = false
    @Published var gettingWorkTime: Date = Calendar.current.date(
        bySettingHour: 9, minute: 0, second: 0, of: Date()
    ) ?? Date()
    @Published var endWorkTime: Date = Calendar.current.date(
        bySettingHour: 18, minute: 0, second: 0, of: Date()
    ) ?? Date()
    @Published var notificationDenied: Bool = false

    // MARK: - Manager
    private let subscriptionManager = SubscriptionManager.shared
    private let notificationManager = NotificationManager.shared
    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UserDefaults Keys
    private let totalNotiKey        = "totalNotiOn"
    private let gettingWorkNotiKey  = "gettingWorkNotiOn"
    private let endWorkNotiKey      = "endWorkNotiOn"
    private let gettingWorkTimeKey  = "gettingWorkTime"
    private let endWorkTimeKey      = "endWorkTime"

    // MARK: - iCloud 연동 (SubscriptionManager 단일 소스)
    var isICloudEnabled: Bool {
        get { SubscriptionManager.shared.isICloudEnabled }
        set { SubscriptionManager.shared.isICloudEnabled = newValue }
    }

    init() {
        loadSavedSettings()
        observeSubscription()
    }

    // MARK: - 저장된 설정 불러오기
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

    // MARK: - 구독 상태 감지
    private func observeSubscription() {
        subscriptionManager.$isSubscribed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.isSubscribed = value
                if !value {
                    self?.setICloud(false)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - iCloud 설정
    func setICloud(_ value: Bool) {
        iCloudOn = value
        subscriptionManager.isICloudEnabled = value
    }

    // MARK: - 알림 전체 설정
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

    // MARK: - 출근 알림 설정
    func setGettingWorkNoti(_ value: Bool) {
        gettingWorkNotiOn = value
        defaults.set(value, forKey: gettingWorkNotiKey)
        if value {
            notificationManager.scheduleCheckInNotification(at: gettingWorkTime)
        } else {
            notificationManager.removeCheckInNotification()
        }
    }

    // MARK: - 퇴근 알림 설정
    func setEndWorkNoti(_ value: Bool) {
        endWorkNotiOn = value
        defaults.set(value, forKey: endWorkNotiKey)
        if value {
            notificationManager.scheduleCheckOutNotification(at: endWorkTime)
        } else {
            notificationManager.removeCheckOutNotification()
        }
    }

    // MARK: - 출근 알림 시간 저장
    func saveGettingWorkTime() {
        defaults.set(gettingWorkTime, forKey: gettingWorkTimeKey)
        if gettingWorkNotiOn {
            notificationManager.scheduleCheckInNotification(at: gettingWorkTime)
        }
    }

    // MARK: - 퇴근 알림 시간 저장
    func saveEndWorkTime() {
        defaults.set(endWorkTime, forKey: endWorkTimeKey)
        if endWorkNotiOn {
            notificationManager.scheduleCheckOutNotification(at: endWorkTime)
        }
    }
}
