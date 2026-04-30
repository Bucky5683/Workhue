//
//  StreakDataEntity.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation
import SwiftData

@Model
class StreakDataEntity {
    @Attribute(.unique) var id: String
    var unlockedColorsRaw: String = ""   // [String] 대신 comma-separated
    var hasNewUnlock: Bool = false
    var customHexListRaw: String = ""    // [String] 대신 comma-separated

    init(id: String = "streakData") {
        self.id = id
    }

    // 편의 프로퍼티
    var unlockedColors: [String] {
        get { unlockedColorsRaw.isEmpty ? [] : unlockedColorsRaw.components(separatedBy: ",") }
        set { unlockedColorsRaw = newValue.joined(separator: ",") }
    }

    var customHexList: [String] {
        get { customHexListRaw.isEmpty ? [] : customHexListRaw.components(separatedBy: ",") }
        set { customHexListRaw = newValue.joined(separator: ",") }
    }
}
