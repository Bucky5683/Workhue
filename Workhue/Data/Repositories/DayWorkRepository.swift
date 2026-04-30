//
//  DayWorkRepository.swift
//  Workhue
//
//  Created by 김서연 on 4/28/26.
//

import Foundation

protocol DayWorkRepository {
    func fetch(by date: Date) async throws -> DayWorkModel?
    func fetchAll() async throws -> [DayWorkModel]
    func save(_ model: DayWorkModel) async throws
    func delete(id: String) async throws
}

final class DayWorkRepositoryImpl: DayWorkRepository {
    private let localDataSource = DayWorkLocalDataSource()
    private let cloudDataSource = DayWorkCloudDataSource()
    private var useICloud: Bool {
        SubscriptionManager.shared.useICloud
    }

    func fetch(by date: Date) async throws -> DayWorkModel? {
        if useICloud {
            return try await cloudDataSource.fetchAll()
                .first { Calendar.current.isDate($0.date, inSameDayAs: date) }?
                .toModel()
        } else {
            return try localDataSource.fetch(by: date)
        }
    }

    func fetchAll() async throws -> [DayWorkModel] {
        if useICloud {
            return try await cloudDataSource.fetchAll().compactMap { $0.toModel() }
        } else {
            return try localDataSource.fetchAll()
        }
    }

    func save(_ model: DayWorkModel) async throws {
        let dto = DayWorkDTO(from: model)
        if useICloud {
            try await cloudDataSource.save(dto)
        } else {
            try localDataSource.save(dto)
        }
    }

    func delete(id: String) async throws {
        if useICloud {
            try await cloudDataSource.delete(id: id)
        } else {
            try localDataSource.delete(id: id)
        }
    }
}
