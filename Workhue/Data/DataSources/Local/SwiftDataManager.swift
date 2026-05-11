//
//  SwiftDataManager.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation
import SwiftData

final class SwiftDataManager {

    static let shared = SwiftDataManager()
    static let preview = SwiftDataManager(inMemory: true)

    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" ||
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PLAYGROUNDS"] == "1"
    }

    let container: ModelContainer

    // context를 lazy로 변경 (호출마다 새로 생성되던 버그 수정)
    lazy var context: ModelContext = {
        ModelContext(container)
    }()

    lazy var localDataSource: DayWorkLocalDataSource = {
        DayWorkLocalDataSource(context: context)
    }()

    lazy var cloudDataSource: DayWorkCloudDataSource = {
        DayWorkCloudDataSource()
    }()

    lazy var syncCoordinator: WorkhueSyncCoordinator = {
        let coordinator = WorkhueSyncCoordinator(
            local: localDataSource,
            cloud: cloudDataSource
        )

        coordinator.onConflict = { [weak self] dto in
            guard let self else { return }
            let resolver = SyncConflictResolver(
                local: self.localDataSource,
                cloud: self.cloudDataSource
            )
            let alert = AlertModel(
                title: "동기화 충돌",
                message: "\(dto.dateKey) 데이터가 다른 기기와 충돌했어요.\n어떤 데이터를 사용할까요?",
                confirmTitle: "서버 데이터 사용",
                cancelTitle: "내 데이터 유지",
                confirmAction: {
                    Task { try? await resolver.resolveWithServer(dateKey: dto.dateKey) }
                },
                cancelAction: {
                    Task {
                        try? await resolver.resolveWithLocal(dateKey: dto.dateKey)
                        await self.syncCoordinator.pushPendingLocalChanges()
                    }
                }
            )
            NavigationRouter.shared.showAlert(alert)
        }

        return coordinator
    }()

    init(inMemory: Bool = false) {
        let useInMemory = inMemory || SwiftDataManager.isPreview

        do {
            container = try ModelContainer(
                for: DayWorkEntity.self,
                WorkCheckListEntity.self,
                StreakDataEntity.self,
                configurations: ModelConfiguration(
                    isStoredInMemoryOnly: useInMemory,
                    cloudKitDatabase: .none  // CloudKit 자동 연동 비활성화
                )
            )
        } catch {
            fatalError("SwiftData 초기화 실패: \(error)")
        }
    }

    func makeDayWorkRepository() -> DayWorkRepository {
        DayWorkRepositoryImpl(local: localDataSource, sync: syncCoordinator)
    }
}
