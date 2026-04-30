//
//  StreakDataEntity.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation
import SwiftData

// 앱 전체에서 단일 레코드로 관리
@Model
class StreakDataEntity {
    var unlockedColors: [String] = []
    var hasNewUnlock: Bool = false
    var customHexList: [String] = []

    init() { }
}
