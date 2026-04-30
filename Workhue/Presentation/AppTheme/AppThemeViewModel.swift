//
//  AppThemeViewModel.swift
//  Workhue
//

import SwiftUI
import UIKit
import Combine

// MARK: - ViewModel

@MainActor
final class AppThemeViewModel: ObservableObject {

    // MARK: - Published

    @Published var selectedThemeMode: AppThemeMode = .system
    @Published var selectedIconType: AppIconType = .primary
    @Published var isSubscribed: Bool = false
    @Published var isChangingIcon: Bool = false
    @Published var alertMessage: String?

    // MARK: - Dependencies

    private let themeStore = AppThemeStore.shared
    private let subscriptionManager = SubscriptionManager.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init() {
        loadInitialState()
        observeThemeMode()
        observeSubscription()
    }

    // MARK: - Load

    private func loadInitialState() {
        selectedThemeMode = themeStore.selectedMode
        selectedIconType = AppIconType.current
        isSubscribed = subscriptionManager.isSubscribed
    }

    // MARK: - Observe

    private func observeThemeMode() {
        themeStore.$selectedMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mode in
                self?.selectedThemeMode = mode
            }
            .store(in: &cancellables)
    }

    private func observeSubscription() {
        subscriptionManager.$isSubscribed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.isSubscribed = value
            }
            .store(in: &cancellables)
    }

    // MARK: - Select Theme

    func selectThemeMode(_ mode: AppThemeMode) {
        withAnimation(.easeInOut(duration: 0.2)) {
            themeStore.setThemeMode(mode)
        }
    }

    // MARK: - Select Icon

    func selectIcon(_ iconType: AppIconType) {
        guard canSelectIcon(iconType) else {
            alertMessage = "이 아이콘은 Premium 전용이에요."
            return
        }

        guard UIApplication.shared.supportsAlternateIcons else {
            alertMessage = "현재 환경에서는 앱 아이콘 변경을 지원하지 않아요."
            return
        }

        guard selectedIconType != iconType else { return }

        isChangingIcon = true

        Task { @MainActor in
            do {
                try await UIApplication.shared.setAlternateIconName(iconType.alternateIconName)
                selectedIconType = iconType
                isChangingIcon = false
            } catch {
                isChangingIcon = false
                alertMessage = "앱 아이콘 변경에 실패했어요.\n\(error.localizedDescription)"
            }
        }
    }

    func canSelectIcon(_ iconType: AppIconType) -> Bool {
        if iconType.isPremiumOnly {
            return isSubscribed
        }

        return true
    }

    func dismissAlert() {
        alertMessage = nil
    }
}
