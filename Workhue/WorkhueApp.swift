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
            }
        }
    }
}
