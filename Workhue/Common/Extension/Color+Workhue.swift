//
//  Color+Workhue.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
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
    
    // MARK: - 해금 (구독 홀로그램) → LinearGradient로 별도 관리
    // Color로 표현 불가 → Gradient+Workhue.swift 별도 파일 권장
    
    // MARK: - 해금 (실버)
    enum UnlockedSpecial {
        static let silver         = Color(hex: "C0C0C0")
    }
}
