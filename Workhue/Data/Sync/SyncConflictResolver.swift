//
//  SyncConflictResolver.swift
//  Workhue
//
//  Created by 김서연 on 5/11/26.
//

import Foundation
import CloudKit

struct SyncConflictResolver {
    private let localDataSource: DayWorkLocalDataSource
    private let cloudDataSource: DayWorkCloudDataSource

    init(local: DayWorkLocalDataSource, cloud: DayWorkCloudDataSource) {
        self.localDataSource = local
        self.cloudDataSource = cloud
    }

    // 서버 데이터로 덮어쓰기
    func resolveWithServer(dateKey: String) async throws {
        guard var serverDTO = try await cloudDataSource.fetch(dateKey: dateKey) else { return }
        serverDTO.syncStatus = SyncStatus.synced.rawValue
        try localDataSource.save(serverDTO)
    }

    // 로컬 데이터 강제 업로드 (updatedAt을 지금으로 올려서 서버 이김)
    func resolveWithLocal(dateKey: String) async throws {
        guard var localDTO = try localDataSource.fetchIncludingDeleted(dateKey: dateKey) else { return }
        localDTO.updatedAt = Date()  // 서버보다 최신으로 만들어서 강제 업로드
        localDTO.syncStatus = SyncStatus.pendingUpload.rawValue
        try localDataSource.save(localDTO)
    }
}
