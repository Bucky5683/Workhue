
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
- 감정 스트릭 + 업무 스트릭 달성 시 특수 색상 해금
- iCloud 동기화 (구독)
- 광고 제거 (구독)
- 다크모드 / 앱 테마 변경 (구독)

---

## 🛠 Tech Stack

| 항목 | 내용 |
|------|------|
| Language | Swift |
| UI Framework | SwiftUI |
| Architecture | Clean Architecture + MVVM |
| State Management | TCA (퇴근 루틴, 색상 선택) |
| Local Storage | UserDefaults |
| Sync | iCloud |
| AI | OpenAI API |
| Subscription | StoreKit 2 |
| AD | Google AdMob |
| Notification | UNUserNotification |

---

## 📂 Project Structure

```
Workhue/
├── Presentation/
│   ├── Home/
│   ├── DayDetail/
│   ├── CheckIn/
│   ├── CheckOut/       ← TCA
│   ├── ColorPicker/    ← TCA
│   ├── StreakReward/
│   ├── Settings/
│   ├── Subscription/
│   ├── AppTheme/
│   └── UnlockedColors/
├── Domain/
│   ├── Models/
│   ├── Repositories/
│   └── UseCases/
└── Data/
    ├── Repositories/
    └── DataSources/
```

---

## 🎨 Color System

| 구분 | 라이트 | 다크 |
|------|--------|------|
| 메인 | `#4A7C59` | `#6AAF80` |
| 서브 | `#8FBC94` | `#5A8C63` |
| 배경 | `#FAFAF7` | `#1C2B1E` |
| 텍스트 | `#2D3A2E` | `#E8F0E9` |
| 포인트 | `#E8A87C` | `#D4845A` |

---

## 📋 Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

---

## 👩‍💻 Developer

| 항목 | 내용 |
|------|------|
| 개발자 | 서연 |
| 기간 | 2025.05 ~ 2025.08 |
| 문의 | *추후 추가* |

---

## 📄 License

MIT License

---
