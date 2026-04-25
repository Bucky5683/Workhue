//
//  WorkhueApp.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import SwiftUI

@main
struct WorkhueApp: App {
    @State private var router = NavigationRouter.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                HomeView()
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        default :
                            HomeView()
                        }
                    }
                    .fullScreenCover(
                        isPresented: .constant(router.presentedView != nil && router.presentationStyle == .fullScreen)
                    ) {
                        router.presentedView
                    }
                    .sheet(
                        isPresented: .constant(router.presentedView != nil && router.presentationStyle == .sheet)
                    ) {
                        router.presentedView
                    }
                    .sheet(
                        isPresented: .constant(router.presentedView != nil && router.presentationStyle == .popover)
                    ) {
                        router.presentedView
                            .presentationDetents([.medium])
                            .presentationCornerRadius(20)
                    }
                    .fullScreenCover(
                        isPresented: .constant(router.presentedView != nil && router.presentationStyle == .overFullScreen)
                    ) {
                        router.presentedView
                            .background(.clear)
                    }
            }
        }
    }
}
