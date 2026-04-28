//
//  SettingView.swift
//  Workhue
//
//  Created by 김서연 on 4/28/26.
//

import SwiftUI

struct SettingView: View {
    @State private var iCloudOn = false
    @State private var totalNotiOn = false {
        didSet {
            if !totalNotiOn {
                gettingWorkNotiOn = false
                endWorkNotiOn = false
            }
        }
    }
    @State private var gettingWorkNotiOn = false
    @State private var endWorkNotiOn = false
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(headerType: .back(""))
                .frame(height: 56)
            HStack {
                Text("이름")
                    .font(.system(size: FontSize.xxl, weight: .bold))
                    .foregroundStyle(Color.System.text)
                Spacer()
                Button {
                    
                } label: {
                    Text("Premium")
                        .font(Font.system(size: FontSize.sm, weight: .regular))
                        .foregroundStyle(Color.System.text)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(height: 30)
                        .background(
                            Color.System.point,
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                }
                .buttonStyle(.plain)
            }.padding(.horizontal, 10)
            Divider()
                .background(Color.System.main)
                .padding(.horizontal, 10)
            Toggle("iCloud 연결", isOn: $iCloudOn)
                .font(.system(size: FontSize.xl, weight: .medium))
                .foregroundStyle(Color.System.pointText)
                .padding(.horizontal, 10)
                .tint(Color.System.main)
            Toggle("알림 설정", isOn: $totalNotiOn)
                .font(.system(size: FontSize.xl, weight: .medium))
                .foregroundStyle(Color.System.pointText)
                .padding(.horizontal, 10)
                .tint(Color.System.main)
            Toggle("출근시간 알림 받기", isOn: $gettingWorkNotiOn)
                .fontWeight(.medium)
                .foregroundStyle(Color.System.pointText)
                .padding(.horizontal, 10)
                .padding(.leading, 10)
                .tint(Color.System.main)
            Toggle("퇴근시간 알림 받기", isOn: $endWorkNotiOn)
                .fontWeight(.medium)
                .foregroundStyle(Color.System.pointText)
                .padding(.horizontal, 10)
                .padding(.leading, 10)
                .tint(Color.System.main)
            Button {
                
            } label: {
                Text("앱 테마")
                    .font(.system(size: FontSize.xl, weight: .medium))
                    .foregroundStyle(Color.System.pointText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .tint(Color.System.text)
            .padding(.horizontal, 10)
            Button(
                role: nil,
                action: {
                    
                },
                label: {
                    HStack {
                        Text("해금 색상")
                            .font(.system(size: FontSize.xl, weight: .medium))
                            .foregroundStyle(Color.System.pointText)
                        Spacer()
                        Text("new!")
                            .font(.system(size: FontSize.xl, weight: .medium))
                            .foregroundStyle(Color.System.point)
                    }
                }
            )
            .tint(Color.System.text)
            .padding(.horizontal, 10)
            Spacer()
        }.padding(20)
            .background(Color.System.background)
    }
}

#Preview {
    SettingView()
}
