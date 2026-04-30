//
//  StreakRewardView.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import SwiftUI

struct StreakRewardView: View {
    let unlockedColors: [WorkColor]
    let onConfirm: () -> Void

    @State private var revealed: Bool = false
    @State private var currentIndex: Int = 0

    private var currentColor: WorkColor {
        unlockedColors[currentIndex]
    }

    var body: some View {
        ZStack {
            // 반투명 배경
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                // 타이틀
                VStack(spacing: 8) {
                    Text("🎉")
                        .font(.system(size: 48))
                    Text("새로운 색상이 해금됐어요!")
                        .font(.system(size: FontSize.lg, weight: .bold))
                        .foregroundStyle(.white)
                    Text("\(currentIndex + 1) / \(unlockedColors.count)")
                        .font(.system(size: FontSize.sm))
                        .foregroundStyle(.white.opacity(0.6))
                        .opacity(unlockedColors.count > 1 ? 1 : 0)
                }

                // 색상 카드
                ZStack {
                    // 해금된 색상
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            currentColor.gradient.map { AnyShapeStyle($0) }
                            ?? AnyShapeStyle(currentColor.color)
                        )
                        .frame(width: 200, height: 200)
                        .opacity(revealed ? 1 : 0)

                    // 마스킹 (해금 전)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 200, height: 200)
                        .overlay {
                            Text("?")
                                .font(.system(size: 72, weight: .bold))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .opacity(revealed ? 0 : 1)
                }
                .animation(.easeInOut(duration: 0.6), value: revealed)
                .onTapGesture {
                    if !revealed { revealed = true }
                }

                // 색상 정보
                VStack(spacing: 6) {
                    Text(revealed ? currentColor.title : "탭해서 확인하기")
                        .font(.system(size: FontSize.lg, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(revealed ? currentColor.description : "")
                        .font(.system(size: FontSize.sm))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .frame(height: 40)
                }
                .animation(.easeInOut(duration: 0.3), value: revealed)

                // 버튼
                if revealed {
                    // 다음 색상이 있으면 다음 버튼, 없으면 확인 버튼
                    if currentIndex < unlockedColors.count - 1 {
                        Button {
                            currentIndex += 1
                            revealed = false
                        } label: {
                            Text("다음")
                                .font(.system(size: FontSize.md, weight: .semibold))
                                .foregroundStyle(Color.System.main)
                                .frame(width: 200)
                                .padding(.vertical, 14)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .transition(.opacity)
                    } else {
                        Button {
                            onConfirm()
                        } label: {
                            Text("확인")
                                .font(.system(size: FontSize.md, weight: .semibold))
                                .foregroundStyle(Color.System.main)
                                .frame(width: 200)
                                .padding(.vertical, 14)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .transition(.opacity)
                    }
                }
            }
            .padding(32)
            .animation(.easeInOut(duration: 0.3), value: revealed)
            .animation(.easeInOut(duration: 0.3), value: currentIndex)
        }
    }
}

#Preview {
    StreakRewardView(
        unlockedColors: [.gold, .pink],
        onConfirm: {}
    )
}
