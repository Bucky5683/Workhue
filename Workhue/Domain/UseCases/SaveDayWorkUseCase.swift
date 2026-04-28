//
//  SaveDayWorkUseCase.swift
//  Workhue
//
//  Created by 김서연 on 4/28/26.
//

import Foundation

struct SaveDayWorkUseCase {
    private let repository: DayWorkRepository

    init(repository: DayWorkRepository) {
        self.repository = repository
    }

    func execute(_ model: DayWorkModel) async throws {
        try await repository.save(model)
    }
}
