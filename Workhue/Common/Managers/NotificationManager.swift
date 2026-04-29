//
//  NotificationManager.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let center = UNUserNotificationCenter.current()

    // MARK: - 권한 요청
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("알림 권한 요청 실패: \(error)")
            return false
        }
    }

    // MARK: - 현재 권한 상태 확인
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - 출근 알림 등록
    func scheduleCheckInNotification(at time: Date) {
        // 기존 출근 알림 제거
        center.removePendingNotificationRequests(withIdentifiers: ["checkIn"])

        let content = UNMutableNotificationContent()
        content.title = "출근할 시간이에요 💼"
        content.body = "오늘도 화이팅!"
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "checkIn", content: content, trigger: trigger)

        center.add(request) { error in
            if let error { print("출근 알림 등록 실패: \(error)") }
        }
    }

    // MARK: - 퇴근 알림 등록
    func scheduleCheckOutNotification(at time: Date) {
        center.removePendingNotificationRequests(withIdentifiers: ["checkOut"])

        let content = UNMutableNotificationContent()
        content.title = "퇴근할 시간이에요 🏠"
        content.body = "오늘 하루 수고했어요!"
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "checkOut", content: content, trigger: trigger)

        center.add(request) { error in
            if let error { print("퇴근 알림 등록 실패: \(error)") }
        }
    }

    // MARK: - 출근 알림 해제
    func removeCheckInNotification() {
        center.removePendingNotificationRequests(withIdentifiers: ["checkIn"])
    }

    // MARK: - 퇴근 알림 해제
    func removeCheckOutNotification() {
        center.removePendingNotificationRequests(withIdentifiers: ["checkOut"])
    }

    // MARK: - 전체 알림 해제
    func removeAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}
