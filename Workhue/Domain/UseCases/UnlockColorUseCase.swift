//
//  UnlockColorUseCase.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

struct UnlockColorUseCase {

    // 조건별 해금 대상 색상 정의
    // 기획서 기준 그대로 매핑
    private func targetColors(for result: StreakResult, isSubscriber: Bool) -> [WorkColor] {
        var targets: [WorkColor] = []

        // 무료 조건
        if result.workStreak >= 3  { targets.append(.gold) }
        if result.workStreak >= 7  { targets.append(.silver) }

        // 구독 전용 조건
        if isSubscriber {
            if result.emotionStreak >= 3 {
                targets.append(contentsOf: [.pink, .mint, .lilac, .peach])
            }
            if result.emotionStreak >= 7 {
                if result.emotionStreak >= 7 {
                    targets.append(contentsOf: [.hologramPink, .hologramOcean, .hologramSunset])
                }
            }
            if result.workStreak >= 3 && result.emotionStreak >= 3 {
                if result.workStreak >= 3 && result.emotionStreak >= 3 {
                    // 기능 해금 (한 번만)
                    let dataSource = StreakLocalDataSource()
                    if !dataSource.isCustomColorUnlocked() {
                        dataSource.setCustomColorUnlocked(true)
                    }
                }
            }
        }

        return targets
    }

    // alreadyUnlocked: UserDefaults에서 불러온 기존 해금 목록
    // 반환값: 이번에 새로 해금된 색상만
    func execute(
        result: StreakResult,
        isSubscriber: Bool,
        alreadyUnlocked: [WorkColor]
    ) -> [WorkColor] {
        let targets = targetColors(for: result, isSubscriber: isSubscriber)
        let newColors = targets.filter { !alreadyUnlocked.contains($0) }
        return newColors
    }
}
