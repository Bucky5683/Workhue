//
//  WorkCheckListEntity.swift
//  Workhue
//

import Foundation
import SwiftData

@Model
class WorkCheckListEntity {
    var id: String
    var content: String
    var isDone: Bool
    var orderIndex: Int = 0  // ✅ 추가

    init(id: String, content: String, isDone: Bool, orderIndex: Int = 0) {
        self.id = id
        self.content = content
        self.isDone = isDone
        self.orderIndex = orderIndex  // ✅ 추가
    }
}
