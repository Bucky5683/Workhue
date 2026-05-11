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
    // MARK: - Sync Metadata
    var dateKey: String = ""          // "yyyy-MM-dd"
    var updatedAt: Date = Date()
    var isDeleted: Bool = false
    var syncStatus: String = SyncStatus.pendingUpload.rawValue
    var cloudRecordName: String? = nil
    var cloudChangeTag: String? = nil
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
            checkList: checkItems
                .sorted { $0.orderIndex < $1.orderIndex }  // ✅ 정렬
                .map { WorkCheckListDTO(id: $0.id, content: $0.content, isDone: $0.isDone, orderIndex: $0.orderIndex) },
            workColor: workColor,
            customHex: customHex,
            // ✅ sync 필드 추가
            dateKey: dateKey,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            syncStatus: syncStatus,
            cloudRecordName: cloudRecordName,
            cloudChangeTag: cloudChangeTag
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
        entity.checkItems = dto.checkList
            .sorted { $0.orderIndex < $1.orderIndex }
            .map {
                WorkCheckListEntity(id: $0.id, content: $0.content, isDone: $0.isDone, orderIndex: $0.orderIndex)
            }
        // ✅ sync 필드 추가
        entity.dateKey = dto.dateKey
        entity.updatedAt = dto.updatedAt
        entity.isDeleted = dto.isDeleted
        entity.syncStatus = dto.syncStatus
        entity.cloudRecordName = dto.cloudRecordName
        entity.cloudChangeTag = dto.cloudChangeTag
        return entity
    }
}
