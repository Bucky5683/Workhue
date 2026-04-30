//
//  StreakModel.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation

// StreakModel: 스트릭 상태를 저장하는 모델
struct StreakModel: Codable {
    var workStreak: Int        // 업무 연속 일수
    var emotionStreak: Int     // 긍정 감정 연속 일수
    var lastWorkDate: Date?    // 마지막 업무 기록일
    var lastEmotionDate: Date? // 마지막 긍정 감정 기록일
}

// StreakResult: UseCase 실행 결과
struct StreakResult {
    var workStreak: Int
    var emotionStreak: Int
    var newlyUnlockedColors: [WorkColor] // 이번에 새로 해금된 색상들
}
