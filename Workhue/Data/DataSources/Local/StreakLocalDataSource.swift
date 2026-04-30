//
//  StreakLocalDataSource.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import Foundation
import SwiftData

struct StreakLocalDataSource {

    private var context: ModelContext {
        SwiftDataManager.shared.context
    }

    // MARK: - 단일 StreakDataEntity fetch or create
    private func fetchOrCreate() throws -> StreakDataEntity {
        let descriptor = FetchDescriptor<StreakDataEntity>()
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        let entity = StreakDataEntity()
        context.insert(entity)
        try context.save()
        return entity
    }

    // MARK: - 해금 색상
    func saveUnlockedColors(_ colors: [WorkColor]) {
        guard let entity = try? fetchOrCreate() else { return }
        entity.unlockedColors = colors.map { $0.rawValue }
        try? context.save()
    }

    func loadUnlockedColors() -> [WorkColor] {
        guard let entity = try? fetchOrCreate() else { return [] }
        return entity.unlockedColors.compactMap { WorkColor(rawValue: $0) }
    }

    // MARK: - new! 뱃지
    func setHasNew(_ value: Bool) {
        guard let entity = try? fetchOrCreate() else { return }
        entity.hasNewUnlock = value
        try? context.save()
    }

    func hasNewUnlock() -> Bool {
        (try? fetchOrCreate())?.hasNewUnlock ?? false
    }

    // MARK: - 커스텀 hex 리스트
    func saveCustomHexList(_ hexList: [String]) {
        guard let entity = try? fetchOrCreate() else { return }
        entity.customHexList = hexList
        try? context.save()
    }

    func loadCustomHexList() -> [String] {
        (try? fetchOrCreate())?.customHexList ?? []
    }

    func addCustomHex(_ hex: String) {
        guard let entity = try? fetchOrCreate() else { return }
        let upper = hex.uppercased()
        if !entity.customHexList.contains(upper) {
            entity.customHexList.append(upper)
            try? context.save()
        }
    }
}
