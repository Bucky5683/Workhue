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

    init(local: DayWorkLocalDataSource, cloud: DayWorkCloudDataSource) {
        self.localDataSource = local
        self.cloudDataSource = cloud  // ✅ cloudDataSource = cloud (자기 자신 대입 수정)
    }

    func syncNow() async {
        async let pull: () = pullRemoteChanges()
        async let push: () = pushPendingLocalChanges()
        _ = await (pull, push)
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
        guard let pending = try? localDataSource.fetchPending() else { return }  // ✅ try?
        for dto in pending {
            do {
                if dto.isDeleted {
                    try await cloudDataSource.delete(dateKey: dto.dateKey)
                    try? localDataSource.updateSyncStatus(id: dto.id, status: .synced)  // ✅ try?
                } else {
                    let changeTag = try await cloudDataSource.save(dto)
                    try? localDataSource.updateCloudMeta(                               // ✅ try?
                        id: dto.id,
                        changeTag: changeTag,
                        status: .synced
                    )
                }
            } catch {
                print("[Sync] push failed:", dto.dateKey, error)
                try? localDataSource.updateSyncStatus(id: dto.id, status: .failed)     // ✅ try?
            }
        }
    }

    private func mergeIntoLocal(_ remote: DayWorkDTO) async {
        guard let local = try? localDataSource.fetch(dateKey: remote.dateKey) else {   // ✅ try?
            try? localDataSource.save(remote.withSyncStatus(.synced))                  // ✅ try?
            return
        }

        if remote.updatedAt > local.updatedAt {
            try? localDataSource.save(remote.withSyncStatus(.synced))                  // ✅ try?
        }
    }
}
