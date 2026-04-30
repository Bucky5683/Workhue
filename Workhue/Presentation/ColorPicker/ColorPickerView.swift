//
//  ColorPickerView.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import SwiftUI

struct ColorPickerView: View {
    let aiColor: WorkColor

    var body: some View {
        Text("ColorPickerView — \(aiColor.title)")
    }
}
