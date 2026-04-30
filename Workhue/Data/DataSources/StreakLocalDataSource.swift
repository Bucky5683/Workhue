//
//  StreakLocalDataSource.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import Foundation

struct StreakLocalDataSource {

    private let unlockedKey        = "unlockedColors"
    private let hasNewKey          = "unlockedColors.hasNew"
    private let customUnlockedKey  = "customColor.isUnlocked"

    func saveUnlockedColors(_ colors: [WorkColor]) {
        let rawValues = colors.map { $0.rawValue }
        UserDefaults.standard.set(rawValues, forKey: unlockedKey)
    }

    func loadUnlockedColors() -> [WorkColor] {
        let rawValues = UserDefaults.standard.stringArray(forKey: unlockedKey) ?? []
        return rawValues.compactMap { WorkColor(rawValue: $0) }
    }

    func setHasNew(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: hasNewKey)
    }

    func hasNewUnlock() -> Bool {
        UserDefaults.standard.bool(forKey: hasNewKey)
    }

    func setCustomColorUnlocked(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: customUnlockedKey)
    }

    func isCustomColorUnlocked() -> Bool {
        UserDefaults.standard.bool(forKey: customUnlockedKey)
    }
}
