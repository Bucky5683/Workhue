//
//  UnlockedColorsViewModel.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation
import SwiftData
import Combine

@MainActor
final class UnlockedColorsViewModel: ObservableObject {

    @Published var unlockedColors: [WorkColor] = []
    @Published var isLoading: Bool = false
    @Published var customHexList: [String] = []

    private let streakRepo: StreakRepositoryImpl

    init() {
        self.streakRepo = StreakRepositoryImpl(context: SwiftDataManager.shared.context)
    }

    var freeUnlockColors: [WorkColor] { [.gold, .roseGold, .forestGreen, .sunsetOrange] }
    var pastelUnlockColors: [WorkColor] { [.pink, .mint, .lilac, .peach] }
    var hologramUnlockColors: [WorkColor] { [.hologramPink, .hologramOcean, .hologramSunset] }

    func isUnlocked(_ color: WorkColor) -> Bool {
        unlockedColors.contains(color)
    }

    func onAppear() {
        Task {
            isLoading = true
            unlockedColors = (try? await streakRepo.loadUnlockedColors()) ?? []
            customHexList = (try? await streakRepo.loadCustomHexList()) ?? []
            try? await streakRepo.setHasNew(false)
            isLoading = false
        }
    }
}
