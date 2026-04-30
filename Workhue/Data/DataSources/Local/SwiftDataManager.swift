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

    var context: ModelContext {
        ModelContext(container)
    }

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
}
