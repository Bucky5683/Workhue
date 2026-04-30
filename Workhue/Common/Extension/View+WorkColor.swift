//
//  View+WorkColor.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import SwiftUI

// WorkColor를 받아서 gradient/단색 자동 분기하는 ViewModifier
extension Shape {
    @ViewBuilder
    func fillWorkColor(_ workColor: WorkColor) -> some View {
        if let gradient = workColor.gradient {
            self.fill(gradient)
        } else {
            self.fill(workColor.color)
        }
    }
}
