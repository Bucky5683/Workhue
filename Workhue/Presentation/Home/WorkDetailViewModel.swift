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
    @Published var goals: [GoalItem] = []

    private var workModel: DayWorkModel
    private let saveUseCase: SaveDayWorkUseCase

    var isEditable: Bool { workModel.status != .beforeWorking }

    init(workModel: DayWorkModel, saveUseCase: SaveDayWorkUseCase) {
        self.workModel = workModel
        self.remembrance = workModel.remembrance ?? ""
        self.goals = workModel.checkList.map {
            GoalItem(id: $0.id, content: $0.content, isDone: $0.isDone, isEditing: false)
        }
        self.saveUseCase = saveUseCase
    }

    // MARK: - 목표 추가
    func addGoal() {
        goals.append(GoalItem(id: UUID().uuidString, content: "", isDone: false, isEditing: true))
    }

    // MARK: - 목표 내용 변경
    func updateGoal(id: String, content: String) {
        if let idx = goals.firstIndex(where: { $0.id == id }) {
            goals[idx].content = content
        }
    }

    // MARK: - 목표 편집 완료
    func commitGoal(id: String) {
        if let idx = goals.firstIndex(where: { $0.id == id }) {
            if goals[idx].content.isEmpty {
                goals.remove(at: idx)
            } else {
                goals[idx].isEditing = false
                saveGoals()
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
        saveGoals()
    }

    // MARK: - 목표 체크 토글
    func toggleGoal(id: String) {
        if let idx = goals.firstIndex(where: { $0.id == id }) {
            goals[idx].isDone.toggle()
            saveGoals()
        }
    }

    // MARK: - 목표 저장
    private func saveGoals() {
        let checkList = goals.map {
            WorkCheckList(id: $0.id, content: $0.content, isDone: $0.isDone)
        }
        let updated = DayWorkModel(
            id: workModel.id,
            date: workModel.date,
            status: workModel.status,
            startTime: workModel.startTime,
            endTime: workModel.endTime,
            remembrance: remembrance,
            checkList: checkList
        )
        Task {
            try? await saveUseCase.execute(updated)
        }
    }

    // MARK: - 회고 저장
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
                checkList: goals.map {
                    WorkCheckList(id: $0.id, content: $0.content, isDone: $0.isDone)
                }
            )
            do {
                try await saveUseCase.execute(updated)
                completion()
            } catch {
                print("회고 저장 실패: \(error)")
            }
            isLoading = false
        }
    }
}
