//
//  CheckStreakUseCase.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation

struct CheckStreakUseCase {

    // 날짜가 캘린더 기준 어제 또는 오늘인지 확인
    // 스트릭은 연속된 날짜 단위로 계산하므로 하루라도 빠지면 초기화
    private func isConsecutive(from previous: Date, to current: Date) -> Bool {
        let calendar = Calendar.current
        let diff = calendar.dateComponents([.day], from: previous, to: current).day ?? 0
        return diff == 1
    }

    // records: 전체 DayWorkModel 배열 (저장된 모든 기록)
    // isSubscriber: 구독 여부 (감정 스트릭 카운트 여부 결정)
    func execute(records: [DayWorkModel], isSubscriber: Bool) -> StreakResult {
        // 날짜 오름차순 정렬
        let sorted = records.sorted { $0.date < $1.date }

        var workStreak = 0
        var emotionStreak = 0
        var lastWorkDate: Date? = nil
        var lastEmotionDate: Date? = nil

        // 각 기록을 순서대로 보면서 연속 일수 계산
        for record in sorted {
            let calendar = Calendar.current
            let recordDay = calendar.startOfDay(for: record.date)

            // 업무 스트릭 조건: 퇴근 완료 + 회고 작성
            let qualifiesWork = record.status == .afterWorking
                && record.remembrance != nil
                && !(record.remembrance!.isEmpty)

            if qualifiesWork {
                if let last = lastWorkDate,
                   isConsecutive(from: last, to: recordDay) {
                    workStreak += 1
                } else {
                    // 연속 아니면 1로 리셋
                    workStreak = 1
                }
                lastWorkDate = recordDay
            } else {
                // 조건 미충족이면 리셋
                workStreak = 0
                lastWorkDate = nil
            }

            // 감정 스트릭 조건: 구독자 + 긍정 색상
            if isSubscriber, let color = record.workColor, color.isPositive {
                if let last = lastEmotionDate,
                   isConsecutive(from: last, to: recordDay) {
                    emotionStreak += 1
                } else {
                    emotionStreak = 1
                }
                lastEmotionDate = recordDay
            } else {
                emotionStreak = 0
                lastEmotionDate = nil
            }
        }

        return StreakResult(
            workStreak: workStreak,
            emotionStreak: emotionStreak,
            newlyUnlockedColors: []  // UnlockColorUseCase에서 채움
        )
    }
}
