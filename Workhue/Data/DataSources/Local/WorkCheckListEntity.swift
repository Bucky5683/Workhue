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

    init(id: String, content: String, isDone: Bool) {
        self.id = id
        self.content = content
        self.isDone = isDone
    }
}
