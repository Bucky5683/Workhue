//
//  StreakRepository.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation
import SwiftData

protocol StreakRepository {
    func saveUnlockedColors(_ colors: [WorkColor]) async throws
    func loadUnlockedColors() async throws -> [WorkColor]
    func setHasNew(_ value: Bool) async throws
    func hasNewUnlock() async throws -> Bool
    func addCustomHex(_ hex: String) async throws
    func loadCustomHexList() async throws -> [String]
}

final class StreakRepositoryImpl: StreakRepository {
    private let local: StreakLocalDataSource
    private let cloud = StreakCloudDataSource()
    private var useICloud: Bool {
        SubscriptionManager.shared.useICloud
    }

    init(context: ModelContext) {
        self.local = StreakLocalDataSource(context: context)
    }

    func saveUnlockedColors(_ colors: [WorkColor]) async throws {
        if useICloud { try await cloud.saveUnlockedColors(colors) }
        else { try local.saveUnlockedColors(colors) }
    }

    func loadUnlockedColors() async throws -> [WorkColor] {
        if useICloud { return try await cloud.loadUnlockedColors() }
        else { return local.loadUnlockedColors() }
    }

    func setHasNew(_ value: Bool) async throws {
        if useICloud { try await cloud.setHasNew(value) }
        else { try local.setHasNew(value) }
    }

    func hasNewUnlock() async throws -> Bool {
        if useICloud { return try await cloud.hasNewUnlock() }
        else { return local.hasNewUnlock() }
    }

    func addCustomHex(_ hex: String) async throws {
        if useICloud { try await cloud.addCustomHex(hex) }
        else { try local.addCustomHex(hex) }
    }

    func loadCustomHexList() async throws -> [String] {
        if useICloud { return try await cloud.loadCustomHexList() }
        else { return local.loadCustomHexList() }
    }
}
