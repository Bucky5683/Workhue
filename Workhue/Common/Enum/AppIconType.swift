//
//  AppIconType.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import UIKit

enum AppIconType: String, CaseIterable, Identifiable {
    case primary
    case dark
    case premium

    var id: String { rawValue }

    /// Xcode의 Alternate App Icon Sets 이름과 반드시 같아야 함.
    /// 기본 아이콘은 nil.
    var alternateIconName: String? {
        /*
         추가 필요
         AppIcon-Dark
         AppIcon-Premium
         */
        switch self {
        case .primary:
            return nil
        case .dark:
            return "AppIcon-Dark"
        case .premium:
            return "AppIcon-Premium"
        }
    }

    var title: String {
        switch self {
        case .primary:
            return "기본 아이콘"
        case .dark:
            return "다크 아이콘"
        case .premium:
            return "프리미엄 아이콘"
        }
    }

    var description: String {
        switch self {
        case .primary:
            return "Workhue의 기본 앱 아이콘이에요."
        case .dark:
            return "어두운 톤의 앱 아이콘이에요."
        case .premium:
            return "구독자 전용 앱 아이콘이에요."
        }
    }

    var isPremiumOnly: Bool {
        switch self {
        case .primary, .dark:
            return false
        case .premium:
            return true
        }
    }

    var symbolName: String {
        switch self {
        case .primary:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .premium:
            return "sparkles"
        }
    }

    static var current: AppIconType {
        let currentName = UIApplication.shared.alternateIconName
        return AppIconType.allCases.first { $0.alternateIconName == currentName } ?? .primary
    }
}
