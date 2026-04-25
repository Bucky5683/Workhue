//
//  Date+Workhue.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import Foundation

extension Date {
    var day: String {
        let calendar = Calendar.current
        return String(calendar.component(.day, from: self))
    }
}
