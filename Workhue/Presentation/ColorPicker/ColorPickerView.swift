//
//  ColorPickerView.swift
//  Workhue
//
//  Created by 김서연 on 5/4/26.
//

import SwiftUI
import ComposableArchitecture

struct ColorPickerView: View {
    let store: StoreOf<ColorPickerFeature>
    let onConfirm: (WorkColor, String?) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(headerType: .back(""))
                .frame(height: 56)
                .padding(.horizontal, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    selectedColorSection
                    basicColorSection
                    unlockedColorSection
                    customHexSection
                }
                .padding(20)
            }

            confirmButton
        }
        .background(Color.System.background)
        .navigationBarHidden(true)
        .onAppear {
            store.send(.onAppear)
        }
        .onChange(of: store.shouldConfirm) { _, newValue in
            if newValue {
                onConfirm(store.selectedColor, store.selectedCustomHex)
            }
        }
    }

    private var selectedColorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Circle()
                    .fill(store.aiColor.color)
                    .frame(width: 56, height: 56)
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.aiColor.title)
                        .font(.system(size: FontSize.md, weight: .semibold))
                        .foregroundStyle(Color.System.text)
                    Text(store.aiColor.description)
                        .font(.system(size: FontSize.sm))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(16)
            .background(Color.System.sub.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if store.selectedColor != store.aiColor || store.selectedCustomHex != nil {
                HStack(spacing: 12) {
                    Circle()
                        .fill(customColor(for: store.selectedColor, hex: store.selectedCustomHex))
                        .frame(width: 32, height: 32)
                    Text(store.selectedColor == .custom
                         ? (store.selectedCustomHex ?? store.selectedColor.title)
                         : store.selectedColor.title)
                        .font(.system(size: FontSize.md))
                        .foregroundStyle(Color.System.text)
                    Spacer()
                }
            }
        }
    }

    private var basicColorSection: some View {
        colorGridSection(
            title: "기본 색상",
            colors: WorkColor.analyzableColors
        )
    }

    private var unlockedColorSection: some View {
        colorGridSection(
            title: "해금 색상",
            colors: [
                .gold, .roseGold, .forestGreen, .sunsetOrange,
                .pink, .mint, .lilac, .peach,
                .silver, .hologramPink, .hologramOcean, .hologramSunset
            ]
        )
    }

    private func customColor(for color: WorkColor, hex: String?) -> Color {
        if color == .custom, let hex {
            return Color(hex: hex)
        }
        return color.color
    }

    private func colorGridSection(
        title: String,
        colors: [WorkColor]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: FontSize.lg, weight: .semibold))
                .foregroundStyle(Color.System.text)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 4),
                spacing: 16
            ) {
                ForEach(colors, id: \.self) { color in
                    Button {
                        store.send(.colorTapped(color))
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 44, height: 44)
                                if store.selectedColor == color {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                if !isColorUnlocked(color) {
                                    Circle()
                                        .fill(.black.opacity(0.45))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white)
                                }
                            }
                            HStack(spacing: 2) {
                                if (!store.isSubscriber || store.dailyFreeUsed) && isColorUnlocked(color) {
                                    Image(systemName: "play.rectangle.fill")
                                        .font(.system(size: 8))
                                        .foregroundStyle(.secondary)
                                }
                                Text(color.title)
                                    .font(.system(size: FontSize.xs))
                                    .foregroundStyle(Color.System.text)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
        }
    }

    private var customHexSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("커스텀 색상")
                .font(.system(size: FontSize.lg, weight: .semibold))
                .foregroundStyle(Color.System.text)

            HStack(spacing: 12) {
                TextField("#FFFFFF", text: .init(
                    get: { store.hexText },
                    set: { store.send(.hexTextChanged($0)) }
                ))
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .padding(12)
                .background(Color.System.sub.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button {
                    store.send(.customHexConfirmTapped)
                } label: {
                    HStack(spacing: 4) {
                        // 구독자도 커스텀 Hex는 광고 필요
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 12))
                        Text("적용")
                            .font(.system(size: FontSize.md, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.System.main)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private var confirmButton: some View {
        Button {
            store.send(.confirmTapped)
        } label: {
            Text("이 색상으로 변경")
                .font(.system(size: FontSize.lg, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.System.main)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
    }

    private func isColorUnlocked(_ color: WorkColor) -> Bool {
        WorkColor.analyzableColors.contains(color)
        || color == .custom
        || store.unlockedColors.contains(color)
    }
}

#Preview("ColorPicker - 기본") {
    ColorPickerView(
        store: Store(
            initialState: ColorPickerFeature.State(
                aiColor: .sunshineYellow,
                selectedColor: .sunshineYellow
            )
        ) {
            ColorPickerFeature()
        },
        onConfirm: { selectedColor, customHex in
            print("선택 색상:", selectedColor, "customHex:", customHex ?? "nil")
        },
        onCancel: {
            print("취소")
        }
    )
}

#Preview("ColorPicker - 해금 색상 포함") {
    ColorPickerView(
        store: Store(
            initialState: ColorPickerFeature.State(
                aiColor: .skyBlue,
                selectedColor: .gold,
                unlockedColors: [
                    .gold, .roseGold, .forestGreen,
                    .pink, .mint, .silver, .hologramOcean
                ],
                customHexList: ["#FFAA00", "#8B5CF6", "#10B981"],
                hexText: "",
                selectedCustomHex: nil,
                isSubscriber: true,
                isLoading: false
            )
        ) {
            ColorPickerFeature()
        },
        onConfirm: { selectedColor, customHex in
            print("선택 색상:", selectedColor, "customHex:", customHex ?? "nil")
        },
        onCancel: {
            print("취소")
        }
    )
}
