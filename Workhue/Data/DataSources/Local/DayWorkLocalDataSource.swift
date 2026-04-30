//
//  DayWorkLocalDataSource.swift
//  Workhue
//
//  Created by 김서연 on 4/28/26.
//

import Foundation
import SwiftData

struct DayWorkLocalDataSource {

    private var context: ModelContext {
        SwiftDataManager.shared.context
    }

    // MARK: - 전체 조회
    func fetchAll() throws -> [DayWorkModel] {
        let descriptor = FetchDescriptor<DayWorkEntity>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        let entities = try context.fetch(descriptor)
        return entities.compactMap { $0.toDTO().toModel() }
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
        let predicate = #Predicate<DayWorkEntity> { $0.id == id }
        var descriptor = FetchDescriptor<DayWorkEntity>(predicate: predicate)
        descriptor.fetchLimit = 1

        if let existing = try context.fetch(descriptor).first {
            // 기존 레코드 업데이트
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
        } else {
            // 신규 삽입
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
