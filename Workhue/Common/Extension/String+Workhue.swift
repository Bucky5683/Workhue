//
//  String+Workhue.swift
//  Workhue
//
//  Created by 김서연 on 5/4/26.
//

extension String {
    var isValidHex: Bool {
        let hex = hasPrefix("#") ? String(dropFirst()) : self
        return hex.count == 6 && hex.allSatisfy(\.isHexDigit)
    }
}
