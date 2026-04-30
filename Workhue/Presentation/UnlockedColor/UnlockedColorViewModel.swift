//
//  UnlockedColorsViewModel.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation
import Combine

@MainActor
final class UnlockedColorsViewModel: ObservableObject {

    @Published var unlockedColors: [WorkColor] = []
    @Published var isLoading: Bool = false

    private let streakRepo = StreakRepositoryImpl()

    var freeUnlockColors: [WorkColor] {
        [.gold, .roseGold, .forestGreen, .sunsetOrange]
    }

    var pastelUnlockColors: [WorkColor] {
        [.pink, .mint, .lilac, .peach]
    }

    var hologramUnlockColors: [WorkColor] {
        [.hologramPink, .hologramOcean, .hologramSunset]
    }

    func isUnlocked(_ color: WorkColor) -> Bool {
        unlockedColors.contains(color)
    }

    func onAppear() {
        Task {
            isLoading = true
            unlockedColors = (try? await streakRepo.loadUnlockedColors()) ?? []
            try? await streakRepo.setHasNew(false)
            isLoading = false
        }
    }
}
