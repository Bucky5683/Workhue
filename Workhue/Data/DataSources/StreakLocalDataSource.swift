//
//  StreakLocalDataSource.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import Foundation

struct StreakLocalDataSource {

    private let unlockedKey  = "unlockedColors"
    private let hasNewKey    = "unlockedColors.hasNew"
    private let customHexListKey = "customColor.hexList"

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

    func saveCustomHexList(_ hexList: [String]) {
        UserDefaults.standard.set(hexList, forKey: customHexListKey)
    }

    func loadCustomHexList() -> [String] {
        UserDefaults.standard.stringArray(forKey: customHexListKey) ?? []
    }

    func addCustomHex(_ hex: String) {
        var list = loadCustomHexList()
        // 중복 제거
        if !list.contains(hex.uppercased()) {
            list.append(hex.uppercased())
            saveCustomHexList(list)
        }
    }
}
