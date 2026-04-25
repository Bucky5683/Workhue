//
//  NavigationRouter.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import SwiftUI

enum Route: Hashable {
    case dayDetail(Date)
    case checkIn
    case checkOut
    case colorPicker
    case settings
}

@Observable
final class NavigationRouter {
    static let shared = NavigationRouter()
    private init() {}
    
    var path: [Route] = []
    
    func push(_ route: Route) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeAll()
    }
}
