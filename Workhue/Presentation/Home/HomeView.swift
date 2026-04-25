//
//  HomeView.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import SwiftUI

struct HomeView: View {
    let screenId: ScreenID = .home
    var workStatus: WorkStatus = .working
    var body: some View {
        VStack(spacing: 10) {
            HeaderView(headerType: .home(false))
                .frame(height: 56)
            Rectangle()
                .frame(height: 30)
                .foregroundStyle(.clear)
            CalendarView(dateModels: [])
                .padding(20)
            HStack(spacing: 10) {
                Text("🏃")
                    .font(.system(size: FontSize.md))
                Text("아직 출근 전이에요")
                    .foregroundStyle(.gray)
                    .font(.system(size: FontSize.md))
                Spacer()
                Button("수정") {
                    print("HI")
                }
                .underline()
                .font(.system(size: FontSize.md))
                .foregroundStyle(.gray)
            }.padding(20)
            Spacer()
            // FAB 버튼
            Button {
                // 상태에 따라 출근/퇴근 루틴 push
            } label: {
                Text(workStatus.icon)
                    .font(.system(size: FontSize.xxl))
                    .frame(width: 72, height: 72)
                    .background(Color.System.point)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(24)
        }.background(Color.System.background)
    }
}
#Preview {
    HomeView()
}
