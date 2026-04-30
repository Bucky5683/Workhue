# Workhue

> 오늘 하루, 무슨 색이었나요?

출퇴근 기록 + 업무 체크리스트 + 회고를 기반으로 AI가 오늘 하루의 감정을 분석하고 색상으로 기록하는 직장인 전용 앱

---

## 📱 Screenshots

*추후 추가 예정*

---

## ✨ Features

- 출퇴근 버튼 하나로 근무 시간 자동 기록
- 업무 목표 체크리스트 작성 및 완료 체크
- 퇴근 후 회고 작성 (최대 300자)
- AI 감정 분석 → 오늘 하루를 색상으로 표현
- 월간 캘린더로 감정 색상 히스토리 시각화
- 꾸준한 출퇴근 / 행복한 하루 연속 달성 시 특수 색상 해금
- 앱 테마 변경 (라이트 / 다크 / 시스템)
- 앱 아이콘 변경
- iCloud 동기화 (구독)
- 광고 제거 (구독)

---

## 🛠 Tech Stack

| 항목 | 내용 |
| --- | --- |
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Architecture | Clean Architecture + MVVM |
| State Management | TCA (ColorPickerView) |
| Local Storage | UserDefaults (SwiftData 전환 예정) |
| Sync | CloudKit (iCloud) |
| AI | OpenAI GPT-4o-mini |
| Subscription | StoreKit 2 (구현 예정) |
| AD | Google AdMob (구현 예정) |
| Notification | UNUserNotification |

---

## 💎 구독 플랜

| 기능 | 무료 | 구독 |
| --- | --- | --- |
| 출퇴근 기록 | ✅ | ✅ |
| 업무 체크리스트 | ✅ | ✅ |
| 회고 + AI 색상 분석 | ✅ | ✅ |
| 꾸준한 출퇴근 색상 해금 | ✅ | ✅ |
| 앱 테마 (라이트/다크/시스템) | ✅ | ✅ |
| 기본 / 다크 아이콘 | ✅ | ✅ |
| 감정 색상 변경 | 광고 1회 | 1회/일 무료, 이후 광고 |
| 커스텀 색상 (Hex 직접 입력) | 광고 1회 | 광고 1회 |
| 행복한 하루 연속 + 특수 색상 해금 | ❌ | ✅ |
| Premium 아이콘 | ❌ | ✅ |
| iCloud 동기화 | ❌ | ✅ |
| 광고 | 있음 | 없음 |

구독 가격: 월 3,900원 / 연 29,900원

---

## 📂 Project Structure

```
Workhue/
├── Presentation/
│   ├── Home/
│   ├── DayDetail/
│   ├── CheckIn/
│   ├── CheckOut/
│   ├── ColorPicker/        ← TCA
│   ├── StreakReward/
│   ├── UnlockedColors/
│   ├── AppTheme/
│   ├── Settings/
│   └── Subscription/
├── Domain/
│   ├── Models/
│   ├── Repositories/       ← Protocol
│   └── UseCases/
├── Data/
│   ├── Repositories/       ← Impl (Local/Cloud 분기)
│   └── DataSources/
│       ├── Local/
│       └── CloudKit/
└── Common/
    ├── Components/
    ├── Extensions/
    ├── Store/
    └── Enum/
```

---

## 🎨 Color System

| 구분 | 라이트 | 다크 |
| --- | --- | --- |
| 메인 | `#4A7C59` | `#6AAF80` |
| 서브 | `#8FBC94` | `#5A8C63` |
| 배경 | `#FAFAF7` | `#1C2B1E` |
| 텍스트 | `#2D3A2E` | `#E8F0E9` |
| 포인트 | `#E8A87C` | `#D4845A` |

감정 색상은 AI 분석 결과 또는 사용자가 직접 선택합니다.
꾸준한 출퇴근 / 행복한 하루 연속 달성 시 골드, 홀로그램 등 특수 색상이 해금됩니다.

---

## 🚦 구현 현황

| 기능 | 상태 |
| --- | --- |
| 홈 / 캘린더 | ✅ 완료 |
| 출근 화면 | ✅ 완료 |
| 퇴근 / 회고 화면 | ✅ 완료 |
| AI 감정 분석 | ✅ 완료 |
| 날짜 상세 화면 | ✅ 완료 |
| 설정 화면 | ✅ 완료 |
| 알림 설정 | ✅ 완료 |
| 연속 기록 시스템 | ✅ 완료 |
| 해금 팝업 (StreakRewardView) | ✅ 완료 |
| 해금 색상 화면 | ✅ 완료 |
| 앱 테마 화면 | ✅ 완료 |
| 앱 아이콘 변경 (구조) | ✅ 완료 (디자인 보류) |
| ColorPickerView | 🔄 구현 예정 (TCA) |
| AdMob 광고 연동 | 🔄 구현 예정 |
| StoreKit 2 실제 결제 | 🔄 구현 예정 |
| OpenAI API Key 백엔드 프록시 | 🔄 구현 예정 |
| CloudKit pagination | 🔄 개선 필요 |
| UserDefaults → SwiftData 전환 | 🔄 검토 중 |

---

## ⚙️ Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

---

## 🔧 Setup

1. 저장소 클론
2. `Workhue/Config.plist` 생성 후 `OPENAI_API_KEY` 추가 (`.gitignore` 처리됨)
3. CloudKit 사용 시 Apple Developer 계정 + iCloud 컨테이너 설정 필요
4. Xcode에서 빌드 및 실행

---

## 👩‍💻 Developer

| 항목 | 내용 |
| --- | --- |
| 개발자 | 서연 |
| 기간 | 2025.05 ~ |
| 문의 | 추후 추가 |

---

## 📄 License

MIT License
