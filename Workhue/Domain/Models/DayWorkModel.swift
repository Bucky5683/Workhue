//
//  DayWorkModel.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import Foundation
import Combine
import SwiftUI

struct DayWorkModel: Sendable {
    let id: String
    let date: Date
    let status: WorkStatus
    let startTime: Date?
    let endTime: Date?
    
    var remembrance: String?
    var checkList: [WorkCheckList] = []
}

struct WorkCheckList: Sendable {
    let id: String
    let content: String
    let isDone: Bool
}
