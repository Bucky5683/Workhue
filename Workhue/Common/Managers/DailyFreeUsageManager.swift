//
//  DailyFreeUsageManager.swift
//  Workhue
//
//  Created by 김서연 on 5/6/26.
//

import Foundation

struct DailyFreeUsageManager {

    private static let key = "colorChange.dailyFreeUsed.date"

    // 오늘 무료 사용했는지 확인
    static func hasUsedToday() -> Bool {
        guard let savedDate = UserDefaults.standard.object(forKey: key) as? Date else {
            return false
        }
        return Calendar.current.isDateInToday(savedDate)
    }

    // 무료 사용 기록
    static func markUsedToday() {
        UserDefaults.standard.set(Date(), forKey: key)
    }
}
