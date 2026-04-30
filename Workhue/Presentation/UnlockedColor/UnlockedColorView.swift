//
//  UnlockedColorsView.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import SwiftUI

struct UnlockedColorsView: View {
    @StateObject private var viewModel = UnlockedColorsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(headerType: .back(""))
                .frame(height: 56)
                .padding(.horizontal, 20)

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 24) {

                        // 기본 색상
                        ColorUnlockSection(
                            title: "기본 색상",
                            subtitle: "처음부터 제공되는 색상",
                            colors: WorkColor.analyzableColors,
                            isUnlocked: { _ in true }
                        )

                        // 꾸준한 출퇴근 (무료)
                        ColorUnlockSection(
                            title: "꾸준한 출퇴근",
                            subtitle: "3일 · 7일 · 14일 · 30일 연속 기록",
                            colors: viewModel.freeUnlockColors,
                            isUnlocked: viewModel.isUnlocked
                        )

                        // 행복한 하루 연속 — 파스텔 (구독)
                        ColorUnlockSection(
                            title: "행복한 하루 연속",
                            subtitle: "긍정 감정 3일 연속",
                            colors: viewModel.pastelUnlockColors,
                            isUnlocked: viewModel.isUnlocked,
                            isPremium: true
                        )

                        // 홀로그램 (구독)
                        ColorUnlockSection(
                            title: "홀로그램",
                            subtitle: "긍정 감정 7일 연속",
                            colors: viewModel.hologramUnlockColors,
                            isUnlocked: viewModel.isUnlocked,
                            isPremium: true
                        )

                        // 커스텀 색상 — 무료/구독 모두, 광고 1회 시청 필요
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("커스텀 색상")
                                    .font(.system(size: FontSize.md, weight: .semibold))
                                    .foregroundStyle(Color.System.text)
                                Text("광고 1회 시청 후 직접 Hex 값으로 색상을 설정할 수 있어요")
                                    .font(.system(size: FontSize.xs))
                                    .foregroundStyle(.secondary)
                            }

                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [.red, .orange, .yellow, .green, .blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 56, height: 56)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("커스텀")
                                        .font(.system(size: FontSize.sm, weight: .semibold))
                                        .foregroundStyle(Color.System.text)
                                    Text("광고 1회 시청 후 사용 가능")
                                        .font(.system(size: FontSize.xs))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(16)
                            .background(Color.System.sub.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(20)
                }
            }
        }
        .background(Color.System.background)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.onAppear()
        }
    }
}

// MARK: - 섹션 컴포넌트
struct ColorUnlockSection: View {
    let title: String
    let subtitle: String
    let colors: [WorkColor]
    let isUnlocked: (WorkColor) -> Bool
    var isPremium: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: FontSize.md, weight: .semibold))
                        .foregroundStyle(Color.System.text)
                    if isPremium { ProBadge() }
                }
                Text(subtitle)
                    .font(.system(size: FontSize.xs))
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(colors, id: \.self) { color in
                    ColorUnlockCell(color: color, isUnlocked: isUnlocked(color))
                }
            }
        }
    }
}

// MARK: - 색상 셀
struct ColorUnlockCell: View {
    let color: WorkColor
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(height: 56)
                    .overlay {
                        if isUnlocked {
                            if let gradient = color.gradient {
                                RoundedRectangle(cornerRadius: 12).fill(gradient)
                            } else {
                                RoundedRectangle(cornerRadius: 12).fill(color.color)
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.3))
                        }
                    }

                if !isUnlocked {
                    Text("?")
                        .font(.system(size: FontSize.md, weight: .bold))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Text(isUnlocked ? color.title : "???")
                .font(.system(size: FontSize.xs))
                .foregroundStyle(isUnlocked ? Color.System.text : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

#Preview {
    UnlockedColorsView()
}
