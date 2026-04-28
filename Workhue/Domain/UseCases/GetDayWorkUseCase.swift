//
//  GetDayWorkUseCase.swift
//  Workhue
//
//  Created by 김서연 on 4/28/26.
//

import Foundation

struct GetDayWorkUseCase {
    private let repository: DayWorkRepository

    init(repository: DayWorkRepository) {
        self.repository = repository
    }

    func execute(date: Date) async throws -> DayWorkModel? {
        try await repository.fetch(by: date)
    }

    func executeAll() async throws -> [DayWorkModel] {
        try await repository.fetchAll()
    }
}
