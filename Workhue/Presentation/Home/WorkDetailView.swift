//
//  WorkDetailView.swift
//  Workhue
//
//  Created by 김서연 on 4/26/26.
//
import SwiftUI

struct WorkDetailView: View {
    let date: Date
    var body: some View {
        VStack {
            HeaderView(headerType: .modal(date.formatted(
                .dateTime
                .month()
                .day()
                .locale(Locale(identifier: "ko_KR"))
            )))
        }
    }
}

#Preview {
    WorkDetailView(date: Date())
}
