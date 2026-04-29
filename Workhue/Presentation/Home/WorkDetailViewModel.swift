//
//  WorkDetailViewModel.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import Foundation
import Combine

@MainActor
final class WorkDetailViewModel: ObservableObject {
    @Published var remembrance: String = ""
    @Published var isLoading: Bool = false
    @Published var savedRememrance: String = ""
    private let workModel: DayWorkModel
    private let saveUseCase: SaveDayWorkUseCase

    init(workModel: DayWorkModel, saveUseCase: SaveDayWorkUseCase) {
        self.workModel = workModel
        self.remembrance = workModel.remembrance ?? ""
        self.saveUseCase = saveUseCase
    }

    func saveRememrance(completion: @escaping () -> Void) {
        Task {
            isLoading = true
            let updated = DayWorkModel(
                id: workModel.id.isEmpty ? UUID().uuidString : workModel.id,
                date: workModel.date,
                status: workModel.status,
                startTime: workModel.startTime,
                endTime: workModel.endTime,
                remembrance: remembrance,
                checkList: workModel.checkList
            )
            do {
                try await saveUseCase.execute(updated)
                completion()  // ← 저장 성공 후 호출
            } catch {
                print("회고 저장 실패: \(error)")
            }
            isLoading = false
        }
    }
}
