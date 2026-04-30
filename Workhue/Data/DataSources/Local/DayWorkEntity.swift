//
//  DayWorkEntity.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation
import SwiftData

@Model
class DayWorkEntity {
    @Attribute(.unique) var id: String
    var date: Date
    var status: String
    var startTime: Date?
    var endTime: Date?
    var workColor: String?
    var customHex: String?
    var remembrance: String?
    @Relationship(deleteRule: .cascade) var checkItems: [WorkCheckListEntity] = []

    init(
        id: String,
        date: Date,
        status: String,
        startTime: Date? = nil,
        endTime: Date? = nil,
        workColor: String? = nil,
        customHex: String? = nil,
        remembrance: String? = nil
    ) {
        self.id = id
        self.date = date
        self.status = status
        self.startTime = startTime
        self.endTime = endTime
        self.workColor = workColor
        self.customHex = customHex
        self.remembrance = remembrance
    }

    // Entity → DTO
    func toDTO() -> DayWorkDTO {
        DayWorkDTO(
            id: id,
            date: date,
            status: status,
            startTime: startTime,
            endTime: endTime,
            remembrance: remembrance,
            checkList: checkItems.map { WorkCheckListDTO(id: $0.id, content: $0.content, isDone: $0.isDone) },
            workColor: workColor,
            customHex: customHex
        )
    }

    // DTO → Entity
    static func from(_ dto: DayWorkDTO) -> DayWorkEntity {
        let entity = DayWorkEntity(
            id: dto.id,
            date: dto.date,
            status: dto.status,
            startTime: dto.startTime,
            endTime: dto.endTime,
            workColor: dto.workColor,
            customHex: dto.customHex,
            remembrance: dto.remembrance
        )
        entity.checkItems = dto.checkList.map {
            WorkCheckListEntity(id: $0.id, content: $0.content, isDone: $0.isDone)
        }
        return entity
    }
}

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
