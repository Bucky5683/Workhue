//
//  CheckInViewModel.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import Foundation
import SwiftData
import Combine

@MainActor
final class CheckInViewModel: ObservableObject {

    @Published var checkInTime: Date = Date()
    @Published var goals: [GoalItem] = []
    @Published var isLoading: Bool = false

    private let saveUseCase: SaveDayWorkUseCase

    init() {
        let repo = SwiftDataManager.shared.makeDayWorkRepository()
        self.saveUseCase = SaveDayWorkUseCase(repository: repo)
    }

    func addGoal() {
        let nextIndex = goals.count  // ✅ 현재 개수 = 다음 인덱스
        goals.append(GoalItem(id: UUID().uuidString, content: "", isDone: false, isEditing: true, orderIndex: nextIndex))
    }

    func updateGoal(id: String, content: String) {
        if let idx = goals.firstIndex(where: { $0.id == id }) {
            goals[idx].content = content
        }
    }

    func commitGoal(id: String) {
        if let idx = goals.firstIndex(where: { $0.id == id }) {
            if goals[idx].content.isEmpty {
                goals.remove(at: idx)
            } else {
                goals[idx].isEditing = false
            }
        }
    }

    func editGoal(id: String) {
        if let idx = goals.firstIndex(where: { $0.id == id }) {
            goals[idx].isEditing = true
        }
    }

    func deleteGoal(id: String) {
        goals.removeAll { $0.id == id }
    }

    func checkIn() {
        Task {
            isLoading = true
            let checkList = goals
                .filter { !$0.content.isEmpty }
                .enumerated()
                .map { index, goal in
                    WorkCheckList(id: goal.id, content: goal.content, isDone: false, orderIndex: index)
                }

            let model = DayWorkModel(
                id: UUID().uuidString,
                date: checkInTime,
                status: .working,
                startTime: checkInTime,
                endTime: nil,
                checkList: checkList
            )
            do {
                try await saveUseCase.execute(model)
                NavigationRouter.shared.pop()
            } catch {
                print("출근 저장 실패: \(error)")
            }
            isLoading = false
        }
    }
}
