//
//  WorkColor.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import SwiftUI

enum WorkColor: String, CaseIterable, Hashable, Codable {
    case sunshineYellow  = "SunshineYellow"
    case skyBlue         = "SkyBlue"
    case mintGreen       = "MintGreen"
    case coralRed        = "CoralRed"
    case lavender        = "Lavender"
    case steelBlue       = "SteelBlue"
    case gold            = "Gold"
    case roseGold        = "RoseGold"
    case forestGreen     = "ForestGreen"
    case sunsetOrange    = "SunsetOrange"
    case pink            = "Pink"
    case mint            = "Mint"
    case lilac           = "Lilac"
    case peach           = "Peach"
    case silver          = "Silver"
    case hologramPink    = "HologramPink"
    case hologramOcean   = "HologramOcean"
    case hologramSunset  = "HologramSunset"
    case custom          = "Custom"  // 추가
    
    enum ColorCategory {
        case basic, unlocked, subscriber
    }

    var category: ColorCategory {
        switch self {
        case .sunshineYellow, .skyBlue, .mintGreen,
             .coralRed, .lavender, .steelBlue:
            return .basic

        case .gold, .roseGold, .forestGreen, .sunsetOrange,
             .pink, .mint, .lilac, .peach, .silver:
            return .unlocked

        case .hologramPink, .hologramOcean, .hologramSunset:
            return .subscriber

        case .custom:
            return .basic  // 커스텀은 그리드에 안 보여주니까 아무거나 OK
        }
    }

    var color: Color {
        switch self {
        case .sunshineYellow:   return Color.Basic.sunshineYellow
        case .skyBlue:          return Color.Basic.skyBlue
        case .mintGreen:        return Color.Basic.mintGreen
        case .coralRed:         return Color.Basic.coralRed
        case .lavender:         return Color.Basic.lavender
        case .steelBlue:        return Color.Basic.steelBlue
        case .gold:             return Color.UnlockedFree.gold
        case .roseGold:         return Color.UnlockedFree.roseGold
        case .forestGreen:      return Color.UnlockedFree.forestGreen
        case .sunsetOrange:     return Color.UnlockedFree.sunsetOrange
        case .pink:             return Color.UnlockedPastel.pink
        case .mint:             return Color.UnlockedPastel.mint
        case .lilac:            return Color.UnlockedPastel.lilac
        case .peach:            return Color.UnlockedPastel.peach
        case .silver:           return Color.UnlockedSpecial.silver
        // 홀로그램은 그라디언트라 대표색만 반환
        case .hologramPink:     return Color(hex: "FF6EB4")
        case .hologramOcean:    return Color(hex: "06B6D4")
        case .hologramSunset:   return Color(hex: "F97316")
        case .custom:           return Color(hex: "D9D9D9")
        }
    }

    // 그라디언트 여부
    var isGradient: Bool {
        switch self {
        case .hologramPink, .hologramOcean, .hologramSunset: return true
        default: return false
        }
    }

    // 그라디언트 반환 (홀로그램만 non-nil)
    var gradient: LinearGradient? {
        switch self {
        case .hologramPink:
            return LinearGradient(
                colors: [Color(hex: "FF6EB4"), Color(hex: "A78BFA")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .hologramOcean:
            return LinearGradient(
                colors: [Color(hex: "06B6D4"), Color(hex: "6366F1")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .hologramSunset:
            return LinearGradient(
                colors: [Color(hex: "F97316"), Color(hex: "EC4899")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return nil
        }
    }

    // 텍스트 색상 (홀로그램은 흰색 고정)
    var textColor: Color {
        switch self {
        case .hologramPink, .hologramOcean, .hologramSunset:
            return .white
        default:
            return Color.System.text
        }
    }

    var title: String {
        switch self {
        case .sunshineYellow:   return "선샤인 옐로우"
        case .skyBlue:          return "스카이 블루"
        case .mintGreen:        return "민트 그린"
        case .coralRed:         return "코랄 레드"
        case .lavender:         return "라벤더"
        case .steelBlue:        return "스틸 블루"
        case .gold:             return "골드"
        case .roseGold:         return "로즈 골드"
        case .forestGreen:      return "포레스트 그린"
        case .sunsetOrange:     return "선셋 오렌지"
        case .pink:             return "핑크"
        case .mint:             return "민트"
        case .lilac:            return "라일락"
        case .peach:            return "피치"
        case .silver:           return "실버"
        case .hologramPink:     return "홀로그램 핑크"
        case .hologramOcean:    return "홀로그램 오션"
        case .hologramSunset:   return "홀로그램 선셋"
        case .custom:           return "커스텀"
        }
    }

    var description: String {
        switch self {
        case .sunshineYellow:   return "햇살처럼 따뜻하고 밝은 노랑. 성취감과 에너지가 넘치는 하루"
        case .skyBlue:          return "맑은 하늘처럼 잔잔하고 여유로운 파랑. 마음이 고요한 하루"
        case .mintGreen:        return "상쾌하고 산뜻한 하루. 긍정 에너지가 넘쳤어요"
        case .coralRed:         return "지치고 힘든 하루. 그래도 수고했어요"
        case .lavender:         return "감성적이고 창의적인 하루. 몽환적인 기분"
        case .steelBlue:        return "차분하고 집중력 있는 하루"
        case .gold:             return "빛나는 성과가 있었던 특별한 하루"
        case .roseGold:         return "따뜻하고 감사한 마음이 가득한 하루"
        case .forestGreen:      return "자연처럼 깊고 안정적인 하루"
        case .sunsetOrange:     return "열정적이고 활기찬 하루"
        case .pink:             return "사랑스럽고 설레는 하루"
        case .mint:             return "청량하고 가벼운 하루"
        case .lilac:            return "몽글몽글하고 감성적인 하루"
        case .peach:            return "달콤하고 포근한 하루"
        case .silver:           return "차갑고 이성적인 하루. 논리적으로 빛났어요"
        case .hologramPink:     return "몽환적인 핑크와 보라의 그라디언트. 특별한 하루"
        case .hologramOcean:    return "깊고 차가운 바다색 그라디언트. 몰입과 집중의 하루"
        case .hologramSunset:   return "타오르는 노을빛 그라디언트. 열정이 가득했던 하루"
        case .custom:           return "내가 직접 고른 색상"
        }
    }

    var isPositive: Bool {
        switch self {
        case .sunshineYellow, .skyBlue, .mintGreen: return true
        default: return false
        }
    }

    static var analyzableColors: [WorkColor] {
        [.sunshineYellow, .skyBlue, .mintGreen, .coralRed, .lavender, .steelBlue]
    }
}
