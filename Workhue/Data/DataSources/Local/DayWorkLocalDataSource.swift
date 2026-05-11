//
//  DayWorkLocalDataSource.swift
//  Workhue
//
//  Created by 김서연 on 4/28/26.
//

import Foundation
import SwiftData

struct DayWorkLocalDataSource {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - 전체 조회
    func fetchAll() throws -> [DayWorkModel] {
        let predicate = #Predicate<DayWorkEntity> { !$0.isDeleted }
        let descriptor = FetchDescriptor<DayWorkEntity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return try context.fetch(descriptor).compactMap { $0.toDTO().toModel() }
    }
    
    // Repository용 (삭제된 것 제외)
    func fetchActive(dateKey: String) throws -> DayWorkDTO? {
        let predicate = #Predicate<DayWorkEntity> {
            $0.dateKey == dateKey && !$0.isDeleted
        }
        var descriptor = FetchDescriptor<DayWorkEntity>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.toDTO()
    }

    // SyncCoordinator용 (삭제된 것 포함)
    func fetchIncludingDeleted(dateKey: String) throws -> DayWorkDTO? {
        let predicate = #Predicate<DayWorkEntity> { $0.dateKey == dateKey }
        var descriptor = FetchDescriptor<DayWorkEntity>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.toDTO()
    }

    // MARK: - 날짜 기준 조회
    func fetch(by date: Date) throws -> DayWorkModel? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        let predicate = #Predicate<DayWorkEntity> {
            $0.date >= start && $0.date < end
        }
        var descriptor = FetchDescriptor<DayWorkEntity>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.toDTO().toModel()
    }

    // MARK: - 저장 (insert or update)
    func save(_ dto: DayWorkDTO) throws {
        let id = dto.id
        let dateKey = dto.dateKey

        // ✅ 1순위: id, 2순위: dateKey로 기존 Entity 탐색
        let predicate = #Predicate<DayWorkEntity> {
            $0.id == id || $0.dateKey == dateKey
        }
        var descriptor = FetchDescriptor<DayWorkEntity>(predicate: predicate)
        descriptor.fetchLimit = 1

        if let existing = try context.fetch(descriptor).first {
            existing.id = dto.id   // ✅ id 충돌 시 최신 id로 덮어쓰기
            existing.status = dto.status
            existing.startTime = dto.startTime
            existing.endTime = dto.endTime
            existing.workColor = dto.workColor
            existing.customHex = dto.customHex
            existing.remembrance = dto.remembrance
            existing.checkItems.forEach { context.delete($0) }
            existing.checkItems = dto.checkList.map {
                WorkCheckListEntity(id: $0.id, content: $0.content, isDone: $0.isDone)
            }
            existing.dateKey = dto.dateKey
            existing.updatedAt = dto.updatedAt
            existing.isDeleted = dto.isDeleted
            existing.syncStatus = dto.syncStatus
            existing.cloudRecordName = dto.cloudRecordName
            existing.cloudChangeTag = dto.cloudChangeTag
        } else {
            let entity = DayWorkEntity.from(dto)
            context.insert(entity)
        }
        try context.save()
    }

    // MARK: - 삭제
    func delete(id: String) throws {
        let predicate = #Predicate<DayWorkEntity> { $0.id == id }
        let descriptor = FetchDescriptor<DayWorkEntity>(predicate: predicate)
        if let entity = try context.fetch(descriptor).first {
            context.delete(entity)
            try context.save()
        }
    }
}

// MARK: - Sync 지원 메서드
extension DayWorkLocalDataSource {

    // dateKey 기준 단건 조회
    func fetch(dateKey: String) throws -> DayWorkDTO? {
        let predicate = #Predicate<DayWorkEntity> { $0.dateKey == dateKey }
        var descriptor = FetchDescriptor<DayWorkEntity>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.toDTO()
    }

    // pendingUpload / pendingDelete 상태인 것만 조회
    func fetchPending() throws -> [DayWorkDTO] {
        let uploadRaw = SyncStatus.pendingUpload.rawValue
        let deleteRaw = SyncStatus.pendingDelete.rawValue
        let failedRaw = SyncStatus.failed.rawValue   // ✅ 추가

        let predicate = #Predicate<DayWorkEntity> {
            $0.syncStatus == uploadRaw ||
            $0.syncStatus == deleteRaw ||
            $0.syncStatus == failedRaw
        }
        return try context.fetch(FetchDescriptor<DayWorkEntity>(predicate: predicate))
            .map { $0.toDTO() }
    }

    // syncStatus만 업데이트
    func updateSyncStatus(id: String, status: SyncStatus) throws {
        let predicate = #Predicate<DayWorkEntity> { $0.id == id }
        var descriptor = FetchDescriptor<DayWorkEntity>(predicate: predicate)
        descriptor.fetchLimit = 1
        guard let entity = try context.fetch(descriptor).first else { return }
        entity.syncStatus = status.rawValue
        try context.save()
    }

    // CloudKit 업로드 성공 후 changeTag + status 저장
    func updateCloudMeta(id: String, changeTag: String?, recordName: String?, status: SyncStatus) throws {
        let predicate = #Predicate<DayWorkEntity> { $0.id == id }
        var descriptor = FetchDescriptor<DayWorkEntity>(predicate: predicate)
        descriptor.fetchLimit = 1
        guard let entity = try context.fetch(descriptor).first else { return }
        entity.cloudChangeTag = changeTag
        entity.cloudRecordName = recordName   // ✅ 추가
        entity.syncStatus = status.rawValue
        try context.save()
    }

    // soft delete (실제 삭제 X, pendingDelete 마킹)
    func markDeleted(id: String) throws {
        let predicate = #Predicate<DayWorkEntity> { $0.id == id }
        var descriptor = FetchDescriptor<DayWorkEntity>(predicate: predicate)
        descriptor.fetchLimit = 1
        guard let entity = try context.fetch(descriptor).first else { return }
        entity.isDeleted = true
        entity.syncStatus = SyncStatus.pendingDelete.rawValue
        entity.updatedAt = Date()
        try context.save()
    }
}
