//
//  ColorPickerFeature.swift
//  Workhue
//
//  Created by 김서연 on 5/4/26.
//

import ComposableArchitecture
import Foundation

@Reducer
struct ColorPickerFeature {
    @ObservableState
    struct State: Equatable {
        let aiColor: WorkColor
        var selectedColor: WorkColor

        var unlockedColors: [WorkColor] = []
        var customHexList: [String] = []

        var hexText: String = ""
        var selectedCustomHex: String?

        var isSubscriber: Bool = false
        var isLoading: Bool = false
        var alertMessage: String?
        var dailyFreeUsed: Bool = false  // 오늘 무료 1회 사용 여부
    }

    enum Action: Equatable {
        case onAppear
        case unlockedColorsLoaded([WorkColor], [String], Bool)

        case colorTapped(WorkColor)
        case hexTextChanged(String)
        case customHexConfirmTapped

        case adWatchRequested(AdTrigger)   // 추가
        case adWatchCompleted(AdTrigger)   // 추가
        case adFailed                      // 추가

        case alertDismissed
    }

    // 광고 트리거 구분용
    enum AdTrigger: Equatable {
        case colorChange(WorkColor)
        case customHex(String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true   // ← 추가
                state.dailyFreeUsed = DailyFreeUsageManager.hasUsedToday()
                return .run { send in
                    let result = await MainActor.run {
                        let context = SwiftDataManager.shared.context
                        let repo = StreakRepositoryImpl(context: context)

                        return (
                            repo: repo,
                            isSubscriber: SubscriptionManager.shared.isSubscribed
                        )
                    }

                    let unlockedColors = (try? await result.repo.loadUnlockedColors()) ?? []
                    let customHexList = (try? await result.repo.loadCustomHexList()) ?? []

                    await send(.unlockedColorsLoaded(
                        unlockedColors,
                        customHexList,
                        result.isSubscriber
                    ))
                }

            case let .unlockedColorsLoaded(colors, hexList, isSubscriber):
                state.isLoading = false  // ← 추가
                state.unlockedColors = colors
                state.customHexList = hexList
                state.isSubscriber = isSubscriber
                return .none

            case let .colorTapped(color):
                guard isSelectable(color, unlockedColors: state.unlockedColors) else {
                    state.alertMessage = "아직 해금되지 않은 색상이에요."
                    return .none
                }

                // 구독자 + 오늘 무료 미사용: 바로 선택
                if state.isSubscriber && !state.dailyFreeUsed {
                    state.selectedColor = color
                    state.selectedCustomHex = nil
                    state.dailyFreeUsed = true
                    DailyFreeUsageManager.markUsedToday()
                    return .none
                }

                // 무료 사용자 or 구독자 1회 초과: 광고 시청
                return .send(.adWatchRequested(.colorChange(color)))

            case let .hexTextChanged(text):
                state.hexText = text.uppercased()
                return .none

            case .customHexConfirmTapped:
                let normalizedHex = normalizeHex(state.hexText)
                guard isValidHex(normalizedHex) else {
                    state.alertMessage = "올바른 Hex 색상을 입력해주세요."
                    return .none
                }

                // 구독자 + 오늘 무료 미사용: 바로 적용
                if state.isSubscriber && !state.dailyFreeUsed {
                    state.selectedColor = .custom
                    state.selectedCustomHex = normalizedHex
                    state.dailyFreeUsed = true
                    DailyFreeUsageManager.markUsedToday()
                    return .none
                }

                // 무료 사용자 or 구독자 1회 초과: 광고 시청
                return .send(.adWatchRequested(.customHex(normalizedHex)))
                
            case .alertDismissed:
                state.alertMessage = nil
                return .none
                
            case let .adWatchRequested(trigger):
                guard RewardedAdManager.shared.isAdReady else {
                    state.alertMessage = "광고를 불러오는 중이에요. 잠시 후 다시 시도해주세요."
                    return .none
                }
                return .run { send in
                    let success = await RewardedAdManager.shared.showAd()
                    if success {
                        await send(.adWatchCompleted(trigger))
                    } else {
                        await send(.adFailed)
                    }
                }

            case let .adWatchCompleted(trigger):
                switch trigger {
                case let .colorChange(color):
                    state.selectedColor = color
                    state.selectedCustomHex = nil
                case let .customHex(hex):
                    state.selectedColor = .custom
                    state.selectedCustomHex = hex
                }
                return .none

            case .adFailed:
                state.alertMessage = "광고를 불러올 수 없어요. 잠시 후 다시 시도해주세요."
                return .none
            }
        }
    }
}

private func isSelectable(
    _ color: WorkColor,
    unlockedColors: [WorkColor]
) -> Bool {
    if WorkColor.analyzableColors.contains(color) {
        return true
    }

    if color == .custom {
        return true
    }

    return unlockedColors.contains(color)
}

private func normalizeHex(_ text: String) -> String {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.hasPrefix("#") {
        return trimmed
    } else {
        return "#\(trimmed)"
    }
}

private func isValidHex(_ text: String) -> Bool {
    let pattern = "^#[0-9A-Fa-f]{6}$"
    return text.range(of: pattern, options: .regularExpression) != nil
}
