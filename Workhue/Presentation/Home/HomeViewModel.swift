//
//  HomeViewModel.swift
//  Workhue
//
//  Created by 김서연 on 4/28/26.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var todayWork: DayWorkModel?
    @Published var allWorks: [DayWorkModel] = []
    @Published var currentStatus: WorkStatus = .beforeWorking
    @Published var isLoading: Bool = false

    private let getUseCase: GetDayWorkUseCase
    private let saveUseCase: SaveDayWorkUseCase

    init(
        getUseCase: GetDayWorkUseCase,
        saveUseCase: SaveDayWorkUseCase
    ) {
        self.getUseCase = getUseCase
        self.saveUseCase = saveUseCase
    }

    func loadToday() {
        Task {
            isLoading = true
            do {
                todayWork = try await getUseCase.execute(date: Date())
                allWorks = try await getUseCase.executeAll()
                currentStatus = todayWork?.status ?? .beforeWorking
            } catch {
                print("불러오기 실패: \(error)")
            }
            isLoading = false
        }
    }

    func checkIn() {
        Task {
            let model = DayWorkModel(
                id: UUID().uuidString,
                date: Date(),
                status: .working,
                startTime: Date(),
                endTime: nil
            )
            do {
                try await saveUseCase.execute(model)
                loadToday()
            } catch {
                print("출근 저장 실패: \(error)")
            }
        }
    }

    func checkOut() {
        guard let work = todayWork else { return }
        Task {
            let updated = DayWorkModel(
                id: work.id,
                date: work.date,
                status: .afterWorking,
                startTime: work.startTime,
                endTime: Date(),
                remembrance: work.remembrance,
                checkList: work.checkList
            )
            do {
                try await saveUseCase.execute(updated)
                loadToday()
            } catch {
                print("퇴근 저장 실패: \(error)")
            }
        }
    }
}
