# Workhue

> 오늘 하루, 무슨 색이었나요?

출퇴근 기록 + 업무 체크리스트 + 회고를 기반으로 AI가 오늘 하루의 감정을 분석하고 색상으로 기록하는 직장인 전용 앱

---

## 📱 Screenshots

*추후 추가 예정*

---

## ✨ Features

- 출퇴근 버튼 하나로 근무 시간 자동 기록
- 퇴근 누락 시 상세화면에서 퇴근 시간 직접 설정 가능
- 업무 목표 체크리스트 작성 및 완료 체크 (순서 보장)
- 퇴근 후 회고 작성 (최대 300자)
- AI 감정 분석 → 오늘 하루를 색상으로 표현
- 월간 캘린더로 감정 색상 히스토리 시각화
- 꾸준한 출퇴근 / 행복한 하루 연속 달성 시 특수 색상 해금
- 앱 테마 변경 (라이트 / 다크 / 시스템)
- 앱 아이콘 변경 (기본 / 다크 / 프리미엄)
- iCloud 동기화 (구독, Local-first + CloudKit Sync)
- 광고 제거 (구독)

---

## 🛠 Tech Stack

| 항목 | 내용 |
| --- | --- |
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Architecture | Clean Architecture + MVVM |
| State Management | TCA (ColorPickerView) |
| Local Storage | SwiftData |
| Sync | CloudKit (iCloud) — Local-first + SyncCoordinator |
| AI | OpenAI GPT-4o-mini (Cloudflare Worker 프록시) |
| Subscription | StoreKit 2 |
| AD | Google AdMob (보상형 광고) |
| Notification | UNUserNotification |

---

## 🔄 iCloud Sync Architecture

구독자가 iCloud를 활성화하면 Local-first 방식으로 동기화합니다.

```
View / ViewModel
      ↓
DayWorkRepository (항상 SwiftData 로컬 조회)
      ↓
DayWorkLocalDataSource (SwiftData)
      ↓
WorkhueSyncCoordinator
      ↓
DayWorkCloudDataSource (CloudKit)
```

**주요 정책**
- 저장: SwiftData 즉시 저장 → `pendingUpload` 마킹 → CloudKit 업로드
- 조회: 항상 SwiftData에서 읽음
- 충돌: `updatedAt` 기준 Last Write Wins, 사용자 선택 Alert 제공
- Soft Delete: `isDeleted` 플래그로 처리, tombstone 유지
- 앱 시작 / Foreground 복귀 시 자동 sync

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
│   ├── Repositories/       ← Protocol (@MainActor)
│   ├── UseCases/
│   └── Sync/               ← SyncStatus, SyncError
├── Data/
│   ├── Repositories/       ← Impl (Local-first)
│   ├── DataSources/
│   │   ├── Local/          ← SwiftData (@MainActor)
│   │   └── CloudKit/       ← CKRecord CRUD
│   └── Sync/               ← WorkhueSyncCoordinator
│       ├── WorkhueSyncCoordinator.swift
│       ├── SyncConflictResolver.swift
│       └── PendingChangeStore.swift
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
| 퇴근 누락 대응 (상세화면 퇴근하기) | ✅ 완료 |
| AI 감정 분석 | ✅ 완료 |
| 날짜 상세 화면 | ✅ 완료 |
| 설정 화면 | ✅ 완료 |
| 알림 설정 | ✅ 완료 |
| 연속 기록 시스템 | ✅ 완료 |
| 해금 팝업 (StreakRewardView) | ✅ 완료 |
| 해금 색상 화면 | ✅ 완료 |
| 앱 테마 화면 | ✅ 완료 |
| 앱 아이콘 변경 (기본 / 다크) | ✅ 완료 |
| ColorPickerView (TCA) | ✅ 완료 |
| StoreKit 2 실제 결제 | ✅ 완료 |
| AdMob 보상형 광고 연동 | ✅ 완료 |
| OpenAI API Key 백엔드 프록시 | ✅ 완료 (Cloudflare Worker) |
| CloudKit pagination | ✅ 완료 |
| iCloud Local-first Sync | ✅ 완료 |
| 충돌 해결 (Last Write Wins + Alert) | ✅ 완료 |
| 체크리스트 순서 보장 (orderIndex) | ✅ 완료 |
| SKAdNetworkItems | ✅ 완료 |

---

## ⚙️ Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

---

## 🔧 Setup

1. 저장소 클론
2. `Workhue/Config.plist` 생성 후 아래 키 추가 (`.gitignore` 처리됨)
   - `BASE_API_URL`: Cloudflare Worker URL
   - `GADRewardedAdUnitID`: AdMob 보상형 광고 단위 ID
3. CloudKit 사용 시 Apple Developer 계정 + iCloud 컨테이너 설정 필요
4. StoreKit 테스트 시 Scheme → Run → Options → StoreKit Configuration 선택
5. Xcode에서 빌드 및 실행

---

## 👩‍💻 Developer

| 항목 | 내용 |
| --- | --- |
| 개발자 | 서연 |
| GitHub | [Seoyeon5683](https://github.com/Seoyeon5683) |
| 기간 | 2026.04 ~ 2026.05 |
| 문의 | bucky5683@gmail.com |

---

## 📄 License

MIT License
