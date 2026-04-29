//
//  CheckOutView.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import SwiftUI

struct CheckOutView: View {
    @StateObject private var viewModel: CheckOutViewModel

    init(workModel: DayWorkModel) {
        _viewModel = StateObject(wrappedValue: CheckOutViewModel(workModel: workModel))
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(headerType: .back(""))
                .frame(height: 56)
                .padding(.horizontal, 20)

            List {
                // 퇴근 시간
                HStack {
                    Text("퇴근 시간")
                        .font(.system(size: FontSize.lg, weight: .semibold))
                        .foregroundStyle(Color.System.pointText)
                    Spacer()
                    Text(viewModel.checkOutTime.formatted(
                        .dateTime.hour().minute()
                        .locale(Locale(identifier: "ko_KR"))
                    ))
                    .font(.system(size: FontSize.lg, weight: .medium))
                    .foregroundStyle(Color.System.text)
                }
                .listRowBackground(Color.System.background)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))

                // 목표 헤더
                Text("목표")
                    .font(.system(size: FontSize.lg, weight: .semibold))
                    .foregroundStyle(Color.System.pointText)
                    .listRowBackground(Color.System.background)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))

                // 목표 셀
                if viewModel.goals.isEmpty {
                    Text("아직 목표가 없어요")
                        .font(.system(size: FontSize.lg))
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.System.background)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                } else {
                    ForEach($viewModel.goals) { $goal in
                        HStack(spacing: 12) {
                            Button {
                                viewModel.toggleGoal(id: goal.id)
                            } label: {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(goal.isDone ? Color.System.main : .clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.System.main, lineWidth: 1.5)
                                    )
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.white)
                                            .opacity(goal.isDone ? 1 : 0)
                                    )
                                    .frame(width: 20, height: 20)
                            }

                            Text(goal.content)
                                .font(.system(size: FontSize.md))
                                .foregroundStyle(goal.isDone ? .secondary : Color.System.text)
                                .strikethrough(goal.isDone)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(Color.System.sub.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .listRowBackground(Color.System.background)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.System.background)

            // 다음 버튼
            Button {
                NavigationRouter.shared.push(.checkOutReview(viewModel.makeUpdatedModel()))
            } label: {
                Text("다음")
                    .font(.system(size: FontSize.lg, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.System.main)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.System.background)
        .navigationBarHidden(true)
    }
}

#Preview {
    CheckOutView(workModel: DayWorkModel(
        id: "test",
        date: Date(),
        status: .working,
        startTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()),
        endTime: nil
    ))
}
