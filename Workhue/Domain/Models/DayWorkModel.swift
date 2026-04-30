//
//  DayWorkModel.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import Foundation

struct DayWorkModel: Hashable, Sendable {
    let id: String
    let date: Date
    let status: WorkStatus
    let startTime: Date?
    let endTime: Date?
    var workColor: WorkColor? = nil
    var customHex: String? = nil
    
    var remembrance: String?
    var checkList: [WorkCheckList] = []
}

struct WorkCheckList: Hashable, Sendable {
    let id: String
    let content: String
    let isDone: Bool
}
