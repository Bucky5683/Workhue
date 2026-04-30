//
//  StreakLocalDataSource.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation

struct StreakLocalDataSource {

    private let unlockedKey = "unlockedColors"
    private let hasNewKey   = "unlockedColors.hasNew"
    private let streakKey   = "streakModel"
    private let customColorUnlockedKey = "customColor.isUnlocked"
    private let customColorAdUsedKey   = "customColor.adUsedDate"

    // 해금된 색상 목록 저장
    // WorkColor.rawValue 배열로 저장
    func saveUnlockedColors(_ colors: [WorkColor]) {
        let rawValues = colors.map { $0.rawValue }
        UserDefaults.standard.set(rawValues, forKey: unlockedKey)
    }

    // 해금된 색상 목록 불러오기
    func loadUnlockedColors() -> [WorkColor] {
        let rawValues = UserDefaults.standard.stringArray(forKey: unlockedKey) ?? []
        return rawValues.compactMap { WorkColor(rawValue: $0) }
    }

    // 새 해금 알림 뱃지 저장 (설정 메뉴 new! 뱃지용)
    func setHasNew(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: hasNewKey)
    }

    func hasNewUnlock() -> Bool {
        UserDefaults.standard.bool(forKey: hasNewKey)
    }

    // 스트릭 카운트 저장/불러오기
    func saveStreak(_ model: StreakModel) {
        if let data = try? JSONEncoder().encode(model) {
            UserDefaults.standard.set(data, forKey: streakKey)
        }
    }

    func loadStreak() -> StreakModel {
        guard let data = UserDefaults.standard.data(forKey: streakKey),
              let model = try? JSONDecoder().decode(StreakModel.self, from: data)
        else {
            return StreakModel(workStreak: 0, emotionStreak: 0)
        }
        return model
    }
    
    // 커스텀 색상 기능 해금 여부
    func setCustomColorUnlocked(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: customColorUnlockedKey)
    }

    func isCustomColorUnlocked() -> Bool {
        UserDefaults.standard.bool(forKey: customColorUnlockedKey)
    }

    // 오늘 광고 시청 여부 (커스텀 색상은 매번 광고 필요하므로 날짜 추적 불필요)
    // → 항상 광고 필요하므로 별도 저장 없이 ColorPickerView에서 상태로만 관리
}
