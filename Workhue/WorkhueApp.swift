//
//  WorkhueApp.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

@main
struct WorkhueApp: App {
    @StateObject private var router = NavigationRouter.shared
    @StateObject private var appThemeStore = AppThemeStore.shared

    // listener Task 유지용
    private let updateListenerTask: Task<Void, Never>
    
    init() {
        // UserDefaults → SwiftData 단 1회 마이그레이션
        MigrationManager.migrateIfNeeded()
        MobileAds.shared.start(completionHandler: nil)
        // 앱 시작 직후 listener 등록 (외부 결제/다른 기기 결제 놓치지 않으려면 여기서)
        updateListenerTask = SubscriptionManager.shared.listenForTransactions()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(router: router)
                .preferredColorScheme(appThemeStore.selectedMode.colorScheme)
                .id(appThemeStore.selectedMode)
                .modelContainer(SwiftDataManager.shared.container)
                .task {
                    // 상품 로드 + 구독 상태 복원
                    await SubscriptionManager.shared.loadProducts()
                    await SubscriptionManager.shared.updateSubscriptionStatus()
                    RewardedAdManager.shared.loadAd()  // 추가
                }
        }
    }
}

struct ContentView: View {
    @ObservedObject var router: NavigationRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .checkIn:
                        CheckInView()

                    case .dayDetail(let model):
                        WorkDetailView(workModel: model)

                    case .checkOut(let model):
                        CheckOutView(workModel: model)

                    case .checkOutReview(let model):
                        CheckOutReviewView(workModel: model)

                    case .settings:
                        SettingView()

                    case .unlockedColors:
                        UnlockedColorsView()

                    case .appTheme:
                        AppThemeView()
                        
                    case .subscription:
                        SubscriptionView()
                    }
                }
                .sheet(
                    isPresented: Binding(
                        get: {
                            router.presentedView != nil &&
                            router.presentationStyle == .sheet
                        },
                        set: {
                            if !$0 {
                                router.dismiss()
                            }
                        }
                    )
                ) {
                    router.presentedView
                }
                .sheet(
                    isPresented: Binding(
                        get: {
                            router.presentedView != nil &&
                            router.presentationStyle == .popover
                        },
                        set: {
                            if !$0 {
                                router.dismiss()
                            }
                        }
                    )
                ) {
                    router.presentedView
                        .presentationDetents([.medium])
                        .presentationCornerRadius(20)
                }
                .fullScreenCover(
                    isPresented: Binding(
                        get: {
                            router.presentedView != nil &&
                            router.presentationStyle == .fullScreen
                        },
                        set: {
                            if !$0 {
                                router.dismiss()
                            }
                        }
                    )
                ) {
                    router.presentedView
                }
                .fullScreenCover(
                    isPresented: Binding(
                        get: {
                            router.presentedView != nil &&
                            router.presentationStyle == .overFullScreen
                        },
                        set: {
                            if !$0 {
                                router.dismiss()
                            }
                        }
                    )
                ) {
                    router.presentedView
                        .background(.clear)
                }
        }
    }
}
