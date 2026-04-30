//
//  AppThemeStore.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import Foundation
import Combine

@MainActor
final class AppThemeStore: ObservableObject {
    static let shared = AppThemeStore()

    @Published private(set) var selectedMode: AppThemeMode

    private let defaults = UserDefaults.standard
    private let themeModeKey = "appThemeMode"

    private init() {
        let savedValue = defaults.string(forKey: themeModeKey)
        selectedMode = AppThemeMode(rawValue: savedValue ?? "") ?? .system
    }

    func setThemeMode(_ mode: AppThemeMode) {
        selectedMode = mode
        defaults.set(mode.rawValue, forKey: themeModeKey)
    }
}
