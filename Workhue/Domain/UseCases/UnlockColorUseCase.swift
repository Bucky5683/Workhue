//
//  UnlockColorUseCase.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

struct UnlockColorUseCase {

    private func targetColors(for result: StreakResult, isSubscriber: Bool) -> [WorkColor] {
        var targets: [WorkColor] = []

        // 무료 조건
        if result.workStreak >= 3 { targets.append(.gold) }
        if result.workStreak >= 7 { targets.append(.silver) }

        // 구독 전용 조건
        if isSubscriber {
            if result.emotionStreak >= 3 {
                targets.append(contentsOf: [.pink, .mint, .lilac, .peach])
            }
            if result.emotionStreak >= 7 {
                targets.append(contentsOf: [.hologramPink, .hologramOcean, .hologramSunset])
            }
        }

        return targets
    }

    // 반환값: 이번에 새로 해금된 색상만
    // 커스텀 색상 해금 여부는 CheckOutReviewViewModel.checkStreak()에서 처리
    func execute(
        result: StreakResult,
        isSubscriber: Bool,
        alreadyUnlocked: [WorkColor]
    ) -> [WorkColor] {
        let targets = targetColors(for: result, isSubscriber: isSubscriber)
        return targets.filter { !alreadyUnlocked.contains($0) }
    }
}
