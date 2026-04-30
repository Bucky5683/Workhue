//
//  Color+Workhue.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import SwiftUI
import UIKit

extension Color {
    init(hex: String) {
        self.init(UIColor(hex: hex))
    }

    init(hex: String, darkHex: String) {
        self = Color.dynamic(
            light: UIColor(hex: hex),
            dark: UIColor(hex: darkHex)
        )
    }

    private static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(
            UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return dark
                default:
                    return light
                }
            }
        )
    }
}

extension Color {
    // MARK: - 기본 색상

    enum Basic {
        static let sunshineYellow = Color(hex: "FFD966")
        static let skyBlue        = Color(hex: "A8C5DA")
        static let mintGreen      = Color(hex: "A8D8B0")
        static let deepBlue       = Color(hex: "2C5F8A")
        static let lightGray      = Color(hex: "D9D9D9")
        static let steelBlue      = Color(hex: "7B9BAF")
        static let sandyOrange    = Color(hex: "F4A460")
        static let coralRed       = Color(hex: "E05C5C")
        static let navyBlue       = Color(hex: "4A6FA5")
        static let lavender       = Color(hex: "9B7FBD")
    }

    // MARK: - 해금 (무료 티어)

    enum UnlockedFree {
        static let gold           = Color(hex: "FFB800")
        static let roseGold       = Color(hex: "E8A598")
        static let forestGreen    = Color(hex: "2D6A4F")
        static let sunsetOrange   = Color(hex: "FF6B35")
    }

    // MARK: - 해금 (구독 파스텔)

    enum UnlockedPastel {
        static let pink           = Color(hex: "FFB3C6")
        static let mint           = Color(hex: "B5EAD7")
        static let lilac          = Color(hex: "C9B8E8")
        static let peach          = Color(hex: "FFDAC1")
    }

    // MARK: - 해금 (실버)

    enum UnlockedSpecial {
        static let silver         = Color(hex: "C0C0C0")
    }

    // MARK: - 시스템 컬러

    enum System {
        /// 메인 색상
        /// - 라이트 모드: 포레스트 그린
        /// - 다크 모드: 라이트 포레스트
        static let main = Color(
            hex: "4A7C59",
            darkHex: "6AAF80"
        )

        /// 서브 색상
        /// - 라이트 모드: 세이지 그린
        /// - 다크 모드: 딥 세이지
        static let sub = Color(
            hex: "8FBC94",
            darkHex: "5A8C63"
        )

        /// 배경 색상
        /// - 라이트 모드: 웜 화이트
        /// - 다크 모드: 딥 포레스트 블랙
        static let background = Color(
            hex: "FAFAF7",
            darkHex: "1C2B1E"
        )

        /// 포인트 텍스트 색상
        /// - 라이트 모드: 다크 포레스트
        /// - 다크 모드: 소프트 화이트
        static let pointText = Color(
            hex: "2D3A2E",
            darkHex: "E8F0E9"
        )

        /// 텍스트 색상
        /// - 라이트 모드: 블랙
        /// - 다크 모드: 화이트
        static let text = Color(
            hex: "000000",
            darkHex: "FFFFFF"
        )

        /// 포인트 색상
        /// - 라이트 모드: 웜 피치
        /// - 다크 모드: 딥 피치
        static let point = Color(
            hex: "E8A87C",
            darkHex: "D4845A"
        )

        /// 카드/서피스
        /// - 라이트 모드: 라이트 세이지
        /// - 다크 모드: 다크 세이지
        static let card = Color(
            hex: "F0F4F0",
            darkHex: "243328"
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hexString = hex
            .replacingOccurrences(of: "#", with: "")
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)

        let red = CGFloat((int >> 16) & 0xFF) / 255
        let green = CGFloat((int >> 8) & 0xFF) / 255
        let blue = CGFloat(int & 0xFF) / 255

        self.init(
            red: red,
            green: green,
            blue: blue,
            alpha: 1
        )
    }
}
