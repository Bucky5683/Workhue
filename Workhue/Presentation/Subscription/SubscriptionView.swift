//
//  SubscriptionView.swift
//  Workhue
//
//  Created by 김서연 on 4/30/26.
//

import SwiftUI
import Combine

struct SubscriptionView: View {

    @StateObject private var viewModel = SubscriptionViewModel()

    private let features: [String] = [
        "광고 없음",
        "iCloud 동기화",
        "행복한 하루 연속 + 특수 색상",
        "앱 테마 / 아이콘 변경",
        "색상 변경 1회/일 무료",
        "언제든 취소 가능"
    ]

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(headerType: .back(""))
                .frame(height: 56)
                .padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 28) {

                    // MARK: - 타이틀
                    Text("Premium")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.System.text)
                        .padding(.top, 8)

                    // MARK: - 플랜 선택
                    HStack(spacing: 16) {
                        PlanCard(
                            title: "월간",
                            price: "월 3,900원",
                            subPrice: nil,
                            badge: nil
                        )

                        PlanCard(
                            title: "연간",
                            price: "연 29,900원",
                            subPrice: "월 2,649원",
                            badge: "추천"
                        )
                    }
                    .padding(.horizontal, 20)

                    // MARK: - 혜택 목록
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(features, id: \.self) { feature in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.square.fill")
                                    .foregroundStyle(Color.System.main)
                                    .font(.system(size: 20))
                                Text(feature)
                                    .font(.system(size: FontSize.md))
                                    .foregroundStyle(Color.System.text)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    // MARK: - 유의 사항
                    VStack(alignment: .leading, spacing: 12) {
                        Text("유의 사항")
                            .font(.system(size: FontSize.md, weight: .semibold))
                            .foregroundStyle(Color.System.text)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .underline()
                            .padding(.horizontal,10)
                            .padding(.top, 10)

                        Text("구독은 구독 기간 종료 24시간 전까지 취소하지 않으면 자동 갱신됩니다.\n(구독 관리 및 취소: 설정 > Apple ID > 구독)")
                            .font(.system(size: FontSize.sm))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal,10)

                        Text("연간 구독은 취소 시 잔여 기간이 환불되지 않으며, 현재 구독 기간 종료일까지 서비스를 이용할 수 있어요.")
                            .font(.system(size: FontSize.sm))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal,10)
                            .padding(.bottom, 10)
                    }
                    .background(Color.System.sub.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)

                    // MARK: - 이용약관 / 개인정보처리방침
                    HStack(spacing: 8) {
                        Button("개인정보처리방침") {
                            if let url = URL(string: "https://www.notion.so/34b732227216802a8646f38b586c15c8") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.system(size: FontSize.xs))
                        .foregroundStyle(.secondary)

                        Text("|")
                            .foregroundStyle(.secondary)
                            .font(.system(size: FontSize.xs))

                        Button("이용약관") {
                            if let url = URL(string: "https://www.notion.so/34b7322272168017af3ac2c9df5a8c09") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.system(size: FontSize.xs))
                        .foregroundStyle(.secondary)
                    }

                    // 하단 버튼 위 여백
                    Spacer().frame(height: 80)
                }
            }

            // MARK: - 하단 구독 버튼
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // 월간 구독
                    Button {
                        viewModel.purchaseMonthly()
                    } label: {
                        Text("월간 구독")
                            .font(.system(size: FontSize.lg, weight: .semibold))
                            .foregroundStyle(Color.System.text)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.System.sub.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    // 연간 구독
                    ZStack(alignment: .top) {
                        Button {
                            viewModel.purchaseYearly()
                        } label: {
                            Text("연간 구독")
                                .font(.system(size: FontSize.lg, weight: .semibold))
                                .foregroundStyle(Color.System.text)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.System.sub.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // 64% 할인 뱃지
                        Text("64% 할인")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.System.main)
                            .clipShape(Capsule())
                            .offset(y: -12)
                    }
                }
                .padding(.horizontal, 20)

                // 구독 복원
                Button("구독 복원") {
                    viewModel.restore()
                }
                .font(.system(size: FontSize.sm))
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            }
            .padding(.top, 8)
            .background(Color.System.background)
        }
        .background(Color.System.background)
        .navigationBarHidden(true)
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
    }
}

// MARK: - 플랜 카드
struct PlanCard: View {
    let title: String
    let price: String
    let subPrice: String?
    let badge: String?

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Group {
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.System.main)
                        .clipShape(Capsule())
                } else {
                    Color.clear
                }
            }
            .frame(height: 20)

            Text(title)
                .font(.system(size: FontSize.md, weight: .medium))
                .foregroundStyle(Color.System.text)

            Divider()

            Text(price)
                .font(.system(size: FontSize.md, weight: .semibold))
                .foregroundStyle(Color.System.text)

            if let subPrice = subPrice {
                Text(subPrice)
                    .font(.system(size: FontSize.sm))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 110, alignment: .top)
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    SubscriptionView()
}
