//
//  GoalItem.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

struct GoalItem: Identifiable {
    let id: String
    var content: String
    var isDone: Bool
    var isEditing: Bool
}
