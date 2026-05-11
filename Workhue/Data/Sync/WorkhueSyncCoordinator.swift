//
//  WorkhueSyncCoordinator.swift
//  Workhue
//
//  Created by 김서연 on 5/11/26.
//

import Foundation

final class WorkhueSyncCoordinator {
    private let localDataSource: DayWorkLocalDataSource
    private let cloudDataSource: DayWorkCloudDataSource

    var onConflict: ((DayWorkDTO) -> Void)?  // ✅ UI 직접 호출 제거

    init(local: DayWorkLocalDataSource, cloud: DayWorkCloudDataSource) {
        self.localDataSource = local
        self.cloudDataSource = cloud
    }

    func syncNow() async {
        let shouldSync = await MainActor.run { SubscriptionManager.shared.useICloud }
        guard shouldSync else { return }
        await pullRemoteChanges()
        await pushPendingLocalChanges()
    }

    func pullRemoteChanges() async {
        let shouldSync = await MainActor.run { SubscriptionManager.shared.useICloud }
        guard shouldSync else { return }
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
        let shouldSync = await MainActor.run { SubscriptionManager.shared.useICloud }
        guard shouldSync else { return }
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
                        recordName: "daywork_\(dto.dateKey)",
                        status: .synced
                    )
                }
            } catch SyncError.serverRecordIsNewer {
                try? localDataSource.updateSyncStatus(id: dto.id, status: .conflict)
                await MainActor.run { self.onConflict?(dto) }  // ✅ 콜백만 호출
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
}
