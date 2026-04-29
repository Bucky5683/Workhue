//
//  SettingView.swift
//  Workhue
//
//  Created by 김서연 on 4/28/26.
//

import SwiftUI

struct SettingView: View {
    @StateObject private var viewModel = SettingViewModel()
    
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
                    // 구독 화면으로 이동
                } label: {
                    Text(viewModel.isSubscribed ? "Premium" : "Free")
                        .font(.system(size: FontSize.sm, weight: .regular))
                        .foregroundStyle(Color.System.text)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(height: 30)
                        .background(Color.System.point, in: RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            
            Divider()
                .background(Color.System.main)
                .padding(.horizontal, 10)
            
            Toggle("iCloud 연결", isOn: Binding(
                get: { viewModel.iCloudOn },
                set: { viewModel.setICloud($0) }
            ))
            .font(.system(size: FontSize.xl, weight: .medium))
            .foregroundStyle(Color.System.pointText)
            .padding(.horizontal, 10)
            .tint(Color.System.main)
            .disabled(!viewModel.isSubscribed)
            .opacity(viewModel.isSubscribed ? 1 : 0.3)
            
            Toggle("알림 설정", isOn: Binding(
                get: { viewModel.totalNotiOn },
                set: { viewModel.setTotalNoti($0) }
            ))
            .font(.system(size: FontSize.xl, weight: .medium))
            .foregroundStyle(Color.System.pointText)
            .padding(.horizontal, 10)
            .tint(Color.System.main)
            
            Toggle("출근시간 알림 받기", isOn: Binding(
                get: { viewModel.gettingWorkNotiOn },
                set: { newValue in
                    viewModel.setGettingWorkNoti(newValue)
                    if newValue {
                        NavigationRouter.shared.present(
                            TimePickerSheet(
                                title: "출근 알림 시간",
                                time: $viewModel.gettingWorkTime
                            ) {
                                viewModel.saveGettingWorkTime()
                                NavigationRouter.shared.dismiss()
                            } onCancel: {
                                viewModel.setGettingWorkNoti(false)
                                NavigationRouter.shared.dismiss()
                            }
                                .presentationDetents([.height(320)])
                                .presentationBackground(Color.System.background),
                            style: .sheet
                        )
                    }
                }
            ))
            .fontWeight(.medium)
            .foregroundStyle(Color.System.pointText)
            .padding(.horizontal, 10)
            .padding(.leading, 10)
            .tint(Color.System.main)
            .disabled(!viewModel.totalNotiOn)
            .opacity(viewModel.totalNotiOn ? 1 : 0.3)
            
            Toggle("퇴근시간 알림 받기", isOn: Binding(
                get: { viewModel.endWorkNotiOn },
                set: { newValue in
                    viewModel.setEndWorkNoti(newValue)
                    if newValue {
                        NavigationRouter.shared.present(
                            TimePickerSheet(
                                title: "퇴근 알림 시간",
                                time: $viewModel.endWorkTime
                            ) {
                                viewModel.saveEndWorkTime()
                                NavigationRouter.shared.dismiss()
                            } onCancel: {
                                viewModel.setEndWorkNoti(false)
                                NavigationRouter.shared.dismiss()
                            }
                                .presentationDetents([.height(320)])
                                .presentationBackground(Color.System.background),
                            style: .sheet
                        )
                    }
                }
            ))
            .fontWeight(.medium)
            .foregroundStyle(Color.System.pointText)
            .padding(.horizontal, 10)
            .padding(.leading, 10)
            .tint(Color.System.main)
            .disabled(!viewModel.totalNotiOn)
            .opacity(viewModel.totalNotiOn ? 1 : 0.3)
            
            Button {
            } label: {
                Text("앱 테마")
                    .font(.system(size: FontSize.xl, weight: .medium))
                    .foregroundStyle(Color.System.pointText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .tint(Color.System.text)
            .padding(.horizontal, 10)
            
            Button {
            } label: {
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
            .tint(Color.System.text)
            .padding(.horizontal, 10)
            
            Spacer()
        }
        .padding(20)
        .background(Color.System.background)
    }
}
// MARK: - 시간 선택 바텀시트
struct TimePickerSheet: View {
    let title: String
    @Binding var time: Date
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("취소") {
                    onCancel()
                }
                .foregroundStyle(.gray)
                
                Spacer()
                
                Text(title)
                    .font(.system(size: FontSize.md, weight: .semibold))
                    .foregroundStyle(Color.System.text)
                
                Spacer()
                
                Button("완료") {
                    onConfirm()
                }
                .foregroundStyle(Color.System.main)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            DatePicker(
                "",
                selection: $time,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
        }
        .background(Color.System.background)
    }
}

#Preview {
    SettingView()
}
