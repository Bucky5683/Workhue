//
//  AppThemeView.swift
//  Workhue
//

import SwiftUI

struct AppThemeView: View {
    @StateObject private var viewModel = AppThemeViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(headerType: .back(""))
                .frame(height: 56)

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    titleSection
                    themeSection
                    iconSection
                    noticeSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color.System.background)
        .alert(
            "앱 테마",
            isPresented: Binding(
                get: { viewModel.alertMessage != nil },
                set: { if !$0 { viewModel.dismissAlert() } }
            )
        ) {
            Button("확인", role: .cancel) {
                viewModel.dismissAlert()
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("앱 테마")
                .font(.system(size: FontSize.xxl, weight: .bold))
                .foregroundStyle(Color.System.text)

            Text("앱의 화면 모드와 홈 화면 아이콘을 변경할 수 있어요.")
                .font(.system(size: FontSize.md, weight: .regular))
                .foregroundStyle(Color.System.pointText)
        }
        .padding(.top, 12)
    }

    // MARK: - Theme Section

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("화면 모드")

            VStack(spacing: 10) {
                ForEach(AppThemeMode.allCases) { mode in
                    ThemeModeRow(
                        mode: mode,
                        isSelected: viewModel.selectedThemeMode == mode
                    ) {
                        viewModel.selectThemeMode(mode)
                    }
                }
            }
        }
    }

    // MARK: - Icon Section

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("앱 아이콘")

            VStack(spacing: 10) {
                ForEach(AppIconType.allCases) { iconType in
                    AppIconRow(
                        iconType: iconType,
                        isSelected: viewModel.selectedIconType == iconType,
                        isEnabled: viewModel.canSelectIcon(iconType),
                        isChanging: viewModel.isChangingIcon
                    ) {
                        viewModel.selectIcon(iconType)
                    }
                }
            }
        }
    }

    // MARK: - Notice

    private var noticeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("안내")
                .font(.system(size: FontSize.md, weight: .semibold))
                .foregroundStyle(Color.System.text)

            Text("앱 아이콘 변경 시 iOS 시스템 알림이 표시될 수 있어요. Premium 아이콘을 제외한 기본 아이콘과 다크 아이콘은 무료로 사용할 수 있어요.")
                .font(.system(size: FontSize.sm, weight: .regular))
                .foregroundStyle(Color.System.pointText)
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            Color.System.sub.opacity(0.15),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: FontSize.xl, weight: .semibold))
            .foregroundStyle(Color.System.text)
    }
}

// MARK: - Theme Row

private struct ThemeModeRow: View {
    let mode: AppThemeMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        } label: {
            HStack(spacing: 14) {
                modeIcon

                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.title)
                        .font(.system(size: FontSize.md, weight: .semibold))
                        .foregroundStyle(Color.System.text)

                    Text(mode.description)
                        .font(.system(size: FontSize.sm, weight: .regular))
                        .foregroundStyle(Color.System.pointText)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.System.main)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.System.sub.opacity(isSelected ? 0.25 : 0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.System.main : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var modeIcon: some View {
        ZStack {
            Circle()
                .fill(Color.System.main.opacity(0.18))
                .frame(width: 42, height: 42)

            Image(systemName: symbolName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.System.main)
        }
    }

    private var symbolName: String {
        switch mode {
        case .system:
            return "iphone"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}

// MARK: - App Icon Row

private struct AppIconRow: View {
    let iconType: AppIconType
    let isSelected: Bool
    let isEnabled: Bool
    let isChanging: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                iconPreview

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(iconType.title)
                            .font(.system(size: FontSize.md, weight: .semibold))
                            .foregroundStyle(Color.System.text)

                        if iconType.isPremiumOnly {
                            ProBadge()
                        }
                    }

                    Text(iconType.description)
                        .font(.system(size: FontSize.sm, weight: .regular))
                        .foregroundStyle(Color.System.pointText)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                trailingIcon
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.System.sub.opacity(isSelected ? 0.25 : 0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.System.main : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .opacity(isEnabled ? 1 : 0.35)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isChanging)
    }

    private var iconPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(previewBackground)
                .frame(width: 46, height: 46)

            Image(systemName: iconType.symbolName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(previewForeground)
        }
    }

    @ViewBuilder
    private var trailingIcon: some View {
        if isChanging && isSelected {
            ProgressView()
        } else if isSelected {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.System.main)
        } else if !isEnabled {
            Image(systemName: "lock.fill")
                .foregroundStyle(Color.System.pointText)
        }
    }

    private var previewBackground: Color {
        switch iconType {
        case .primary:
            return Color.System.main
        case .dark:
            return Color.System.text
        case .premium:
            return Color.System.point
        }
    }

    private var previewForeground: Color {
        switch iconType {
        case .primary:
            return Color.System.background
        case .dark:
            return Color.System.background
        case .premium:
            return Color.System.text
        }
    }
}

#Preview {
    AppThemeView()
}
