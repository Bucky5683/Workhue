//
//  CalendarDay.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//
import Foundation

enum CalendarDay: Hashable {
    case empty(Int)   // 빈 셀 (index로 구분)
    case day(Date)    // 실제 날짜
}
