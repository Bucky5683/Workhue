//
//  MigrationManager.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation
import SwiftData

// UserDefaults → SwiftData 단 1회 마이그레이션
@MainActor
struct MigrationManager {

    private static let migrationKey = "migration.swiftdata.v1"

    static func migrateIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }

        migrateDayWorkList()
        migrateStreakData()

        UserDefaults.standard.set(true, forKey: migrationKey)
        print("SwiftData 마이그레이션 완료")
    }

    // MARK: - DayWork 마이그레이션
    private static func migrateDayWorkList() {
        guard
            let data = UserDefaults.standard.data(forKey: "dayWorkList"),
            let dtos = try? JSONDecoder().decode([DayWorkDTO].self, from: data)
        else { return }

        let context = SwiftDataManager.shared.context
        for dto in dtos {
            let entity = DayWorkEntity.from(dto)
            context.insert(entity)
        }
        try? context.save()
        // 마이그레이션 완료 후 UserDefaults 정리
        UserDefaults.standard.removeObject(forKey: "dayWorkList")
        print("DayWork \(dtos.count)개 마이그레이션 완료")
    }

    // MARK: - Streak 데이터 마이그레이션
    private static func migrateStreakData() {
        let unlockedColors = UserDefaults.standard.stringArray(forKey: "unlockedColors") ?? []
        let hasNew = UserDefaults.standard.bool(forKey: "unlockedColors.hasNew")
        let customHexList = UserDefaults.standard.stringArray(forKey: "customColor.hexList") ?? []

        guard !unlockedColors.isEmpty || hasNew || !customHexList.isEmpty else { return }

        let context = SwiftDataManager.shared.context
        let entity = StreakDataEntity()
        entity.unlockedColors = unlockedColors
        entity.hasNewUnlock = hasNew
        entity.customHexList = customHexList
        context.insert(entity)
        try? context.save()

        // 마이그레이션 완료 후 UserDefaults 정리
        UserDefaults.standard.removeObject(forKey: "unlockedColors")
        UserDefaults.standard.removeObject(forKey: "unlockedColors.hasNew")
        UserDefaults.standard.removeObject(forKey: "customColor.hexList")
        print("Streak 데이터 마이그레이션 완료")
    }
}
