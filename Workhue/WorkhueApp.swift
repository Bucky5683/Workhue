//
//  WorkhueApp.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import SwiftUI
import SwiftData

@main
struct WorkhueApp: App {
    @StateObject private var router = NavigationRouter.shared
    @StateObject private var appThemeStore = AppThemeStore.shared

    init() {
        // UserDefaults → SwiftData 단 1회 마이그레이션
        MigrationManager.migrateIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(router: router)
                .preferredColorScheme(appThemeStore.selectedMode.colorScheme)
                .id(appThemeStore.selectedMode)
                .modelContainer(SwiftDataManager.shared.container)
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

                    case .colorPicker(let aiColor):
                        ColorPickerView(aiColor: aiColor)

                    case .settings:
                        SettingView()

                    case .unlockedColors:
                        UnlockedColorsView()

                    case .appTheme:
                        AppThemeView()
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
