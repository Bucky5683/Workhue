//
//  SwiftDataManager.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataManager {
    static let shared = SwiftDataManager()

    let container: ModelContainer

    var context: ModelContext {
        container.mainContext
    }

    private init() {
        let schema = Schema([
            DayWorkEntity.self,
            WorkCheckListEntity.self,
            StreakDataEntity.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("SwiftData ModelContainer 생성 실패: \(error)")
        }
    }
}
