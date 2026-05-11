//
//  DayWorkRepository.swift
//  Workhue
//
//  Created by 김서연 on 4/28/26.
//

import Foundation
import SwiftData

protocol DayWorkRepository {
    func fetch(by date: Date) async throws -> DayWorkModel?
    func fetchAll() async throws -> [DayWorkModel]
    func save(_ model: DayWorkModel) async throws
    func delete(id: String) async throws
}

final class DayWorkRepositoryImpl: DayWorkRepository {
    private let localDataSource: DayWorkLocalDataSource
    private let syncCoordinator: WorkhueSyncCoordinator?

    init(local: DayWorkLocalDataSource, sync: WorkhueSyncCoordinator? = nil) {
        self.localDataSource = local
        self.syncCoordinator = sync
    }

    func fetchAll() async throws -> [DayWorkModel] {
        try localDataSource.fetchAll()  // ✅ 이미 [DayWorkModel] 반환
    }

    func fetch(by date: Date) async throws -> DayWorkModel? {
        try localDataSource.fetchActive(dateKey: date.dateKey)?.toModel()
    }

    func save(_ model: DayWorkModel) async throws {
        var dto = DayWorkDTO(from: model)
        dto.updatedAt = Date()
        dto.dateKey = model.date.dateKey
        dto.syncStatus = SyncStatus.pendingUpload.rawValue

        try localDataSource.save(dto)  // ✅ try 추가
        await syncCoordinator?.pushPendingLocalChanges()
    }

    func delete(id: String) async throws {
        try localDataSource.markDeleted(id: id)  // ✅ try 추가
        await syncCoordinator?.pushPendingLocalChanges()
    }
}
