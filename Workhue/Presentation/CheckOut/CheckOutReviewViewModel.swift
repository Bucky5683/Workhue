//
//  CheckOutReviewViewModel.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import Foundation
import Combine

@MainActor
final class CheckOutReviewViewModel: ObservableObject {

    @Published var remembrance: String = ""
    @Published var analyzedColor: WorkColor? = nil
    @Published var isAnalyzing: Bool = false
    @Published var isLoading: Bool = false

    private let workModel: DayWorkModel
    private let saveUseCase: SaveDayWorkUseCase
    private let getUseCase: GetDayWorkUseCase
    private let openAI = OpenAIManager.shared

    init(workModel: DayWorkModel) {
        self.workModel = workModel
        self.remembrance = workModel.remembrance ?? ""
        let repo = DayWorkRepositoryImpl()
        self.saveUseCase = SaveDayWorkUseCase(repository: repo)
        self.getUseCase = GetDayWorkUseCase(repository: repo)
    }

    // MARK: - 회고 분석
    func analyzeRememrance() {
        guard !remembrance.isEmpty else { return }
        Task {
            isAnalyzing = true
            do {
                analyzedColor = try await openAI.analyzeEmotion(from: remembrance)
            } catch {
                print("분석 실패: \(error)")
                analyzedColor = .steelBlue
            }
            isAnalyzing = false
        }
    }

    // MARK: - 색상 변경
    func changeColor(_ color: WorkColor) {
        analyzedColor = color
    }

    // MARK: - 퇴근 저장
    func checkOut() {
        Task {
            isLoading = true
            let updated = DayWorkModel(
                id: workModel.id,
                date: workModel.date,
                status: .afterWorking,
                startTime: workModel.startTime,
                endTime: workModel.endTime,
                workColor: analyzedColor,
                remembrance: remembrance,
                checkList: workModel.checkList
            )
            do {
                try await saveUseCase.execute(updated)
                await checkStreak()
                NavigationRouter.shared.popToRoot()
            } catch {
                print("퇴근 저장 실패: \(error)")
            }
            isLoading = false
        }
    }

    // MARK: - 스트릭 체크
    private func checkStreak() async {
        let repo = DayWorkRepositoryImpl()
        let getUseCase = GetDayWorkUseCase(repository: repo)
        let records = (try? await getUseCase.executeAll()) ?? []

        let streakResult = CheckStreakUseCase().execute(
            records: records,
            isSubscriber: SubscriptionManager.shared.isSubscribed
        )

        let streakRepo = StreakRepositoryImpl()
        let alreadyUnlocked = (try? await streakRepo.loadUnlockedColors()) ?? []
        let newColors = UnlockColorUseCase().execute(
            result: streakResult,
            isSubscriber: SubscriptionManager.shared.isSubscribed,
            alreadyUnlocked: alreadyUnlocked
        )

        if !newColors.isEmpty {
            try? await streakRepo.saveUnlockedColors(alreadyUnlocked + newColors)
            try? await streakRepo.setHasNew(true)
            // TODO: StreakRewardView 팝업 트리거
        }
    }
}
