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
    }

    enum Action: Equatable {
        case onAppear
        case unlockedColorsLoaded([WorkColor], [String], Bool)

        case colorTapped(WorkColor)
        case hexTextChanged(String)
        case customHexConfirmTapped

        case alertDismissed
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true   // ← 추가
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

                state.selectedColor = color
                state.selectedCustomHex = nil
                return .none

            case let .hexTextChanged(text):
                state.hexText = text.uppercased()
                return .none

            case .customHexConfirmTapped:
                let normalizedHex = normalizeHex(state.hexText)
                guard isValidHex(normalizedHex) else {
                    state.alertMessage = "올바른 Hex 색상을 입력해주세요."
                    return .none
                }
                state.selectedColor = .custom
                state.selectedCustomHex = normalizedHex
                // 저장은 CheckOutReviewViewModel에서만 함
                return .none
            case .alertDismissed:
                state.alertMessage = nil
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
