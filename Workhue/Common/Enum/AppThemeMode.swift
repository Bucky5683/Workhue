//
//  AppThemeMode.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import SwiftUI

enum AppThemeMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return "시스템 설정 맞춤"
        case .light:
            return "라이트 모드"
        case .dark:
            return "다크 모드"
        }
    }

    var description: String {
        switch self {
        case .system:
            return "기기의 화면 모드 설정을 그대로 따라가요."
        case .light:
            return "항상 밝은 화면으로 앱을 보여줘요."
        case .dark:
            return "항상 어두운 화면으로 앱을 보여줘요."
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
