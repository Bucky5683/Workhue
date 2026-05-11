//
//  WorkhueSyncCoordinator.swift
//  Workhue
//
//  Created by 김서연 on 5/11/26.
//

import Foundation
import SwiftUI

final class WorkhueSyncCoordinator {
    private let localDataSource: DayWorkLocalDataSource
    private let cloudDataSource: DayWorkCloudDataSource
    private let conflictResolver: SyncConflictResolver

    init(local: DayWorkLocalDataSource, cloud: DayWorkCloudDataSource) {
        self.localDataSource = local
        self.cloudDataSource = cloud  // ✅ cloudDataSource = cloud (자기 자신 대입 수정)
    }

    func syncNow() async {
        await pullRemoteChanges()   // ✅ pull 먼저
        await pushPendingLocalChanges()  // ✅ push 나중
    }

    func pullRemoteChanges() async {
        do {
            let remoteAll = try await cloudDataSource.fetchAll()
            for remote in remoteAll {
                await mergeIntoLocal(remote)
            }
        } catch {
            print("[Sync] pull failed:", error)
        }
    }

    func pushPendingLocalChanges() async {
        guard let pending = try? localDataSource.fetchPending() else { return }
        for dto in pending {
            do {
                if dto.isDeleted {
                    try await cloudDataSource.delete(dateKey: dto.dateKey)
                    try? localDataSource.updateSyncStatus(id: dto.id, status: .synced)
                } else {
                    let changeTag = try await cloudDataSource.save(dto)
                    try? localDataSource.updateCloudMeta(
                        id: dto.id,
                        changeTag: changeTag,
                        recordName: "daywork_\(dto.dateKey)",  // ✅ recordName도 저장
                        status: .synced
                    )
                }
            } catch SyncError.serverRecordIsNewer {
                try? localDataSource.updateSyncStatus(id: dto.id, status: .conflict)
                await MainActor.run {
                    showConflictAlert(for: dto)
                }
            } catch {
                print("[Sync] push failed:", dto.dateKey, error)
                try? localDataSource.updateSyncStatus(id: dto.id, status: .failed)
            }
        }
    }

    private func mergeIntoLocal(_ remote: DayWorkDTO) async {
        guard let local = try? localDataSource.fetchIncludingDeleted(dateKey: remote.dateKey) else {
            try? localDataSource.save(remote.withSyncStatus(.synced))
            return
        }
        if remote.updatedAt > local.updatedAt {
            try? localDataSource.save(remote.withSyncStatus(.synced))
        }
    }
    
    private func showConflictAlert(for dto: DayWorkDTO) {
        let alert = AlertModel(
            title: "동기화 충돌",
            message: "\(dto.dateKey) 데이터가 다른 기기와 충돌했어요.\n어떤 데이터를 사용할까요?",
            confirmTitle: "서버 데이터 사용",
            cancelTitle: "내 데이터 유지",
            confirmAction: {
                Task {
                    try? await self.conflictResolver.resolveWithServer(dateKey: dto.dateKey)
                }
            },
            cancelAction: {
                Task {
                    try? await self.conflictResolver.resolveWithLocal(dateKey: dto.dateKey)
                }
            }
        )
        NavigationRouter.shared.showAlert(alert)  // ✅ 이미 있는 메서드 사용
    }
}
