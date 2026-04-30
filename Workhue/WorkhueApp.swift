//
//  WorkhueApp.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import SwiftUI

@main
struct WorkhueApp: App {
    @StateObject private var router = NavigationRouter.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(router: router)
        }
    }
}

struct ContentView: View {
    @ObservedObject var router: NavigationRouter  // ← 여기서 감지

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
                    }
                }
                .sheet(
                    isPresented: Binding(
                        get: { router.presentedView != nil && router.presentationStyle == .sheet },
                        set: { if !$0 { router.dismiss() } }  // 드래그로 닫으면 dismiss 호출
                    )
                ) {
                    router.presentedView
                }
                .sheet(
                    isPresented: Binding(
                        get: { router.presentedView != nil && router.presentationStyle == .popover },
                        set: { if !$0 { router.dismiss() } }
                    )
                ) {
                    router.presentedView
                        .presentationDetents([.medium])
                        .presentationCornerRadius(20)
                }
                .fullScreenCover(
                    isPresented: Binding(
                        get: { router.presentedView != nil && router.presentationStyle == .fullScreen },
                        set: { if !$0 { router.dismiss() } }
                    )
                ) {
                    router.presentedView
                }
                .fullScreenCover(
                    isPresented: Binding(
                        get: { router.presentedView != nil && router.presentationStyle == .overFullScreen },
                        set: { if !$0 { router.dismiss() } }
                    )
                ) {
                    router.presentedView
                        .background(.clear)
                }
        }
    }
}
