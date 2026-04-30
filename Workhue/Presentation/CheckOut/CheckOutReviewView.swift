//
//  CheckOutReviewView.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import SwiftUI

struct CheckOutReviewView: View {
    @StateObject private var viewModel: CheckOutReviewViewModel

    init(workModel: DayWorkModel) {
        _viewModel = StateObject(wrappedValue: CheckOutReviewViewModel(workModel: workModel))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(headerType: .back(""))
                    .frame(height: 56)
                    .padding(.horizontal, 20)

                ScrollView {
                    VStack(spacing: 20) {

                        // 회고 입력
                        VStack(alignment: .trailing, spacing: 4) {
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $viewModel.remembrance)
                                    .onChange(of: viewModel.remembrance) { newValue in
                                        if newValue.count > 300 {
                                            viewModel.remembrance = String(newValue.prefix(300))
                                        }
                                    }
                                    .scrollContentBackground(.hidden)
                                    .background(.clear)
                                    .foregroundStyle(Color.System.text)
                                    .frame(height: 200)
                                if viewModel.remembrance.isEmpty {
                                    Text("오늘 하루를 기록해보세요")
                                        .foregroundStyle(.secondary)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                }
                            }
                            Text("\(viewModel.remembrance.count)/300")
                                .font(.system(size: FontSize.xs))
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .background(Color.System.sub.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // 확인 버튼 (AI 분석)
                        if viewModel.analyzedColor == nil {
                            Button {
                                viewModel.analyzeRememrance()
                            } label: {
                                Text("확인")
                                    .font(.system(size: FontSize.lg, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        viewModel.remembrance.isEmpty
                                            ? Color.System.main.opacity(0.3)
                                            : Color.System.main
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(viewModel.remembrance.isEmpty)
                        }

                        // 색상 결과
                        if let color = viewModel.analyzedColor {
                            VStack(spacing: 12) {
                                Text("오늘의 색상")
                                    .font(.system(size: FontSize.lg, weight: .semibold))
                                    .foregroundStyle(Color.System.pointText)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                HStack(spacing: 16) {
                                    Circle()
                                        .fill(color.color)
                                        .frame(width: 56, height: 56)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(color.title)
                                            .font(.system(size: FontSize.md, weight: .semibold))
                                            .foregroundStyle(Color.System.text)
                                        Text(color.description)
                                            .font(.system(size: FontSize.sm))
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(16)
                                .background(Color.System.sub.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                                // 색상 변경 버튼
                                Button {
                                    NavigationRouter.shared.push(.colorPicker(color))
                                } label: {
                                    Text("색상 변경")
                                        .font(.system(size: FontSize.md))
                                        .foregroundStyle(Color.System.main)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.System.sub.opacity(0.3))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                    }
                    .padding(20)
                }

                // 퇴근 버튼
                if viewModel.analyzedColor != nil {
                    Button {
                        viewModel.checkOut()
                    } label: {
                        Text("퇴근")
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
            }
            .background(Color.System.background)
            .navigationBarHidden(true)

            // 로딩/분석 오버레이
            if viewModel.isAnalyzing || viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                    Text(viewModel.isAnalyzing ? "AI가 오늘 하루를 분석하고 있어요..." : "저장 중...")
                        .font(.system(size: FontSize.md))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    CheckOutReviewView(workModel: DayWorkModel(
        id: "test",
        date: Date(),
        status: .afterWorking,
        startTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()),
        endTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())
    ))
}
