//
//  CheckOutViewModel.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import Foundation
import Combine

@MainActor
final class CheckOutViewModel: ObservableObject {

    // MARK: - Output
    @Published var checkOutTime: Date = Date()
    @Published var goals: [GoalItem] = []
    @Published var isLoading: Bool = false

    private let workModel: DayWorkModel
    private let saveUseCase: SaveDayWorkUseCase

    init(workModel: DayWorkModel) {
        self.workModel = workModel
        self.checkOutTime = Date()
        self.goals = workModel.checkList.map {
            GoalItem(id: $0.id, content: $0.content, isDone: $0.isDone, isEditing: false)
        }
        let repo = DayWorkRepositoryImpl()
        self.saveUseCase = SaveDayWorkUseCase(repository: repo)
    }

    // MARK: - 목표 체크 토글
    func toggleGoal(id: String) {
        if let idx = goals.firstIndex(where: { $0.id == id }) {
            goals[idx].isDone.toggle()
        }
    }

    // MARK: - 다음 버튼 → CheckOutReviewView로 넘길 모델 생성
    func makeUpdatedModel() -> DayWorkModel {
        DayWorkModel(
            id: workModel.id,
            date: workModel.date,
            status: .afterWorking,
            startTime: workModel.startTime,
            endTime: checkOutTime,
            remembrance: workModel.remembrance,
            checkList: goals.map {
                WorkCheckList(id: $0.id, content: $0.content, isDone: $0.isDone)
            }
        )
    }
}
