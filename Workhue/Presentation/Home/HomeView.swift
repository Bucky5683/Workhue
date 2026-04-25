//
//  HomeView.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import SwiftUI

struct HomeView: View {
    let screenId: ScreenID = .home
    var body: some View {
        VStack {
            HeaderView(headerType: .home(false))
                .frame(height: 56)
            Spacer()
        }
    }
}
#Preview {
    HomeView()
}
