//
//  CheckInView.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import SwiftUI

struct CheckInView: View {
    @StateObject private var viewModel = CheckInViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HeaderView(headerType: .back(""))
                    .frame(height: 56)

                // 출근 시간 표시
                HStack {
                    Text("출근 시간")
                        .font(.system(size: FontSize.lg, weight: .semibold))
                        .foregroundStyle(Color.System.pointText)
                    Spacer()
                    Text(viewModel.checkInTime.formatted(
                        .dateTime.hour().minute()
                        .locale(Locale(identifier: "ko_KR"))
                    ))
                    .font(.system(size: FontSize.lg, weight: .medium))
                    .foregroundStyle(Color.System.text)
                }
                .padding(.horizontal, 10)

                Divider()
                    .background(Color.System.main)
                    .padding(.horizontal, 10)

                // 목표 헤더
                HStack {
                    Text("목표")
                        .font(.system(size: FontSize.lg, weight: .semibold))
                        .foregroundStyle(Color.System.pointText)
                    Spacer()
                    Button {
                        viewModel.addGoal()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.System.main)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 10)

                // 목표 리스트
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach($viewModel.goals) { $goal in
                            GoalCell(
                                goal: $goal,
                                onCommit: { viewModel.commitGoal(id: goal.id) },
                                onEdit: { viewModel.editGoal(id: goal.id) },
                                onDelete: { viewModel.deleteGoal(id: goal.id) }
                            )
                        }
                    }
                    .padding(.horizontal, 10)
                }

                Spacer()

                // 출근 버튼
                Button {
                    viewModel.checkIn()
                } label: {
                    Text("출근")
                        .font(.system(size: FontSize.lg, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.System.main)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 10)
            }
            .padding(20)
            .background(Color.System.background)
            .disabled(viewModel.isLoading)

            if viewModel.isLoading {
                Color.black.opacity(0.2).ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - GoalCell
struct GoalCell: View {
    @Binding var goal: GoalItem
    let onCommit: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // 체크박스 (출근 전이라 비활성)
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.System.main, lineWidth: 1.5)
                .frame(width: 20, height: 20)

            if goal.isEditing {
                // 편집 모드
                TextField("목표를 입력하세요", text: $goal.content)
                    .font(.system(size: FontSize.md))
                    .foregroundStyle(Color.System.text)
                    .onSubmit { onCommit() }
                    .submitLabel(.done)
            } else {
                // 표시 모드
                Text(goal.content)
                    .font(.system(size: FontSize.md))
                    .foregroundStyle(Color.System.text)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button("수정") { onEdit() }
                    .font(.system(size: FontSize.sm))
                    .underline()
                    .foregroundStyle(.gray)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color.System.sub.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
    }
}

#Preview {
    CheckInView()
}
