//
//  CheckInViewModel.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import Foundation
import Combine

@MainActor
final class CheckInViewModel: ObservableObject {

    // MARK: - Output
    @Published var checkInTime: Date = Date()
    @Published var goals: [GoalItem] = []
    @Published var isLoading: Bool = false

    // MARK: - UseCase
    private let saveUseCase: SaveDayWorkUseCase

    init() {
        let repo = DayWorkRepositoryImpl()
        self.saveUseCase = SaveDayWorkUseCase(repository: repo)
    }

    // MARK: - 목표 추가
    func addGoal() {
        let newGoal = GoalItem(id: UUID().uuidString, content: "", isDone: false, isEditing: true)
        goals.append(newGoal)
    }

    // MARK: - 목표 내용 변경
    func updateGoal(id: String, content: String) {
        if let idx = goals.firstIndex(where: { $0.id == id }) {
            goals[idx].content = content
        }
    }

    // MARK: - 목표 편집 완료 (엔터)
    func commitGoal(id: String) {
        if let idx = goals.firstIndex(where: { $0.id == id }) {
            if goals[idx].content.isEmpty {
                goals.remove(at: idx)  // 내용 없으면 제거
            } else {
                goals[idx].isEditing = false
            }
        }
    }

    // MARK: - 목표 수정 모드
    func editGoal(id: String) {
        if let idx = goals.firstIndex(where: { $0.id == id }) {
            goals[idx].isEditing = true
        }
    }

    // MARK: - 목표 삭제
    func deleteGoal(id: String) {
        goals.removeAll { $0.id == id }
    }

    // MARK: - 출근 저장
    func checkIn() {
        Task {
            isLoading = true
            let checkList = goals
                .filter { !$0.content.isEmpty }
                .map { WorkCheckList(id: $0.id, content: $0.content, isDone: false) }

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
