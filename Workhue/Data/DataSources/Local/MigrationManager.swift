//
//  MigrationManager.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation
import SwiftData

@MainActor
struct MigrationManager {

    private static let migrationKey = "migration.swiftdata.v1"

    static func migrateIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }

        let dayWorkSuccess = migrateDayWorkList()
        let streakSuccess = migrateStreakData()

        if dayWorkSuccess && streakSuccess {
            UserDefaults.standard.set(true, forKey: migrationKey)
            print("SwiftData 마이그레이션 완료")
        } else {
            print("SwiftData 마이그레이션 일부 실패 - 다음 실행 시 재시도")
        }
    }

    // MARK: - DayWork 마이그레이션
    @discardableResult
    private static func migrateDayWorkList() -> Bool {
        guard
            let data = UserDefaults.standard.data(forKey: "dayWorkList"),
            let dtos = try? JSONDecoder().decode([DayWorkDTO].self, from: data)
        else {
            return true
        }

        let context = SwiftDataManager.shared.context

        let existingIds: Set<String>
        do {
            let descriptor = FetchDescriptor<DayWorkEntity>()
            existingIds = Set(try context.fetch(descriptor).map { $0.id })
        } catch {
            print("DayWork 기존 데이터 조회 실패: \(error)")
            return false
        }

        for dto in dtos {
            guard !existingIds.contains(dto.id) else { continue }
            let entity = DayWorkEntity.from(dto)
            context.insert(entity)
        }

        do {
            try context.save()
            UserDefaults.standard.removeObject(forKey: "dayWorkList")
            print("DayWork \(dtos.count)개 마이그레이션 완료")
            return true
        } catch {
            print("DayWork 마이그레이션 저장 실패: \(error)")
            return false
        }
    }

    // MARK: - Streak 데이터 마이그레이션
    @discardableResult
    private static func migrateStreakData() -> Bool {
        let unlockedColors = UserDefaults.standard.stringArray(forKey: "unlockedColors") ?? []
        let hasNew = UserDefaults.standard.bool(forKey: "unlockedColors.hasNew")
        let customHexList = UserDefaults.standard.stringArray(forKey: "customColor.hexList") ?? []

        guard !unlockedColors.isEmpty || hasNew || !customHexList.isEmpty else {
            return true
        }

        let context = SwiftDataManager.shared.context

        do {
            let predicate = #Predicate<StreakDataEntity> { $0.id == "streakData" }
            let descriptor = FetchDescriptor<StreakDataEntity>(predicate: predicate)

            if let existing = try context.fetch(descriptor).first {
                // 기존 SwiftData 데이터와 UserDefaults 데이터 merge
                existing.unlockedColors = Array(Set(existing.unlockedColors + unlockedColors))
                existing.customHexList = Array(Set(existing.customHexList + customHexList))
                existing.hasNewUnlock = existing.hasNewUnlock || hasNew
            } else {
                let entity = StreakDataEntity()
                entity.unlockedColors = unlockedColors
                entity.hasNewUnlock = hasNew
                entity.customHexList = customHexList
                context.insert(entity)
            }

            try context.save()
            UserDefaults.standard.removeObject(forKey: "unlockedColors")
            UserDefaults.standard.removeObject(forKey: "unlockedColors.hasNew")
            UserDefaults.standard.removeObject(forKey: "customColor.hexList")
            print("Streak 데이터 마이그레이션 완료")
            return true
        } catch {
            print("Streak 마이그레이션 저장 실패: \(error)")
            return false
        }
    }
}
