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
        if result.workStreak >= 3  { targets.append(.gold) }
        if result.workStreak >= 7  { targets.append(.roseGold) }
        if result.workStreak >= 14 { targets.append(.forestGreen) }
        if result.workStreak >= 30 { targets.append(.sunsetOrange) }

        // 구독 전용 조건
        if isSubscriber {
            if result.workStreak >= 3 && result.emotionStreak >= 3 {
                targets.append(.silver)
            }
            if result.emotionStreak >= 3 {
                targets.append(contentsOf: [.pink, .mint, .lilac, .peach])
            }
            if result.emotionStreak >= 7 {
                targets.append(contentsOf: [.hologramPink, .hologramOcean, .hologramSunset])
            }
        }

        return targets
    }

    func execute(
        result: StreakResult,
        isSubscriber: Bool,
        alreadyUnlocked: [WorkColor]
    ) -> [WorkColor] {
        let targets = targetColors(for: result, isSubscriber: isSubscriber)
        return targets.filter { !alreadyUnlocked.contains($0) }
    }
}
