//
//  StreakRepository.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation

protocol StreakRepository {
    func saveUnlockedColors(_ colors: [WorkColor]) async throws
    func loadUnlockedColors() async throws -> [WorkColor]
    func setHasNew(_ value: Bool) async throws
    func hasNewUnlock() async throws -> Bool
    func saveCustomHex(_ hex: String)
    func loadCustomHex() -> String?
}

final class StreakRepositoryImpl: StreakRepository {

    private let local = StreakLocalDataSource()
    private let cloud = StreakCloudDataSource()
    private var useICloud: Bool {
        SubscriptionManager.shared.useICloud
    }

    func saveUnlockedColors(_ colors: [WorkColor]) async throws {
        if useICloud {
            try await cloud.saveUnlockedColors(colors)
        } else {
            local.saveUnlockedColors(colors)
        }
    }

    func loadUnlockedColors() async throws -> [WorkColor] {
        if useICloud {
            return try await cloud.loadUnlockedColors()
        } else {
            return local.loadUnlockedColors()
        }
    }

    func setHasNew(_ value: Bool) async throws {
        if useICloud {
            try await cloud.setHasNew(value)
        } else {
            local.setHasNew(value)
        }
    }

    func hasNewUnlock() async throws -> Bool {
        if useICloud {
            return try await cloud.hasNewUnlock()
        } else {
            return local.hasNewUnlock()
        }
    }

    // 커스텀 hex는 구독 여부 상관없이 항상 UserDefaults
    func saveCustomHex(_ hex: String) {
        local.saveCustomHex(hex)
    }

    func loadCustomHex() -> String? {
        local.loadCustomHex()
    }
}
