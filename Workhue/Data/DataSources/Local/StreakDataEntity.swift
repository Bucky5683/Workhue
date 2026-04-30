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
    var unlockedColors: [String] = []
    var hasNewUnlock: Bool = false
    var customHexList: [String] = []

    init(id: String = "streakData") {
        self.id = id
    }
}
