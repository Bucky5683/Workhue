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
        var dailyFreeUsed: Bool = false
        var shouldConfirm: Bool = false
    }

    enum Action: Equatable {
        case onAppear
        case unlockedColorsLoaded([WorkColor], [String], Bool)

        case colorTapped(WorkColor)
        case hexTextChanged(String)
        case customHexConfirmTapped
        case confirmTapped

        case adWatchRequested(AdTrigger)
        case adWatchCompleted(AdTrigger)
        case adFailed
    }

    enum AdTrigger: Equatable {
        case colorChange(WorkColor)
        case customHex(String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            case .onAppear:
                state.isLoading = true
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
                    await send(.unlockedColorsLoaded(unlockedColors, customHexList, result.isSubscriber))
                }

            case let .unlockedColorsLoaded(colors, hexList, isSubscriber):
                state.isLoading = false
                state.unlockedColors = colors
                state.customHexList = hexList
                state.isSubscriber = isSubscriber
                return .none

            case let .colorTapped(color):
                guard isSelectable(color, unlockedColors: state.unlockedColors) else {
                    return .run { _ in
                        await MainActor.run {
                            NavigationRouter.shared.showAlert(AlertModel(
                                title: "안내",
                                message: "아직 해금되지 않은 색상이에요.",
                                confirmTitle: "확인",
                                cancelTitle: ""
                            ))
                        }
                    }
                }
                state.selectedColor = color
                state.selectedCustomHex = nil
                return .none

            case let .hexTextChanged(text):
                state.hexText = text.uppercased()
                return .none

            case .customHexConfirmTapped:
                let normalizedHex = normalizeHex(state.hexText)
                guard isValidHex(normalizedHex) else {
                    return .run { _ in
                        await MainActor.run {
                            NavigationRouter.shared.showAlert(AlertModel(
                                title: "안내",
                                message: "올바른 Hex 색상을 입력해주세요.",
                                confirmTitle: "확인",
                                cancelTitle: ""
                            ))
                        }
                    }
                }
                // 구독 여부 상관없이 광고
                return .send(.adWatchRequested(.customHex(normalizedHex)))

            case .confirmTapped:
                // 기본 색상은 광고 없이 바로
                if WorkColor.analyzableColors.contains(state.selectedColor) {
                    state.shouldConfirm = true
                    return .none
                }
                // 구독자 + 오늘 무료 미사용
                if state.isSubscriber && !state.dailyFreeUsed {
                    state.dailyFreeUsed = true
                    DailyFreeUsageManager.markUsedToday()
                    state.shouldConfirm = true
                    return .none
                }
                // 광고 필요
                return .send(.adWatchRequested(.colorChange(state.selectedColor)))

            case let .adWatchRequested(trigger):
                guard RewardedAdManager.shared.isAdReady else {
                    return .run { _ in
                        await MainActor.run {
                            NavigationRouter.shared.showAlert(AlertModel(
                                title: "안내",
                                message: "광고를 불러오는 중이에요. 잠시 후 다시 시도해주세요.",
                                confirmTitle: "확인",
                                cancelTitle: ""
                            ))
                        }
                    }
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
                state.shouldConfirm = true
                return .none

            case .adFailed:
                return .run { _ in
                    await MainActor.run {
                        NavigationRouter.shared.showAlert(AlertModel(
                            title: "안내",
                            message: "광고를 불러올 수 없어요. 잠시 후 다시 시도해주세요.",
                            confirmTitle: "확인",
                            cancelTitle: ""
                        ))
                    }
                }
            }
        }
    }
}

private func isSelectable(
    _ color: WorkColor,
    unlockedColors: [WorkColor]
) -> Bool {
    if WorkColor.analyzableColors.contains(color) { return true }
    if color == .custom { return true }
    return unlockedColors.contains(color)
}

private func normalizeHex(_ text: String) -> String {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.hasPrefix("#") ? trimmed : "#\(trimmed)"
}

private func isValidHex(_ text: String) -> Bool {
    let pattern = "^#[0-9A-Fa-f]{6}$"
    return text.range(of: pattern, options: .regularExpression) != nil
}
