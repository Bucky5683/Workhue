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

enum PresentationStyle {
    case fullScreen      // 전체화면
    case sheet           // 바텀시트
    case popover         // 말풍선 팝업
    case overFullScreen  // 배경 투명 전체화면 (Alert용)
}

@Observable
final class NavigationRouter {
    static let shared = NavigationRouter()
    private init() {}
    
    var presentedView: AnyView? = nil
    var presentationStyle: PresentationStyle = .fullScreen
    
    var path: [Route] = []
    
    func push(_ route: Route) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func present(_ view: some View, style: PresentationStyle = .fullScreen) {
        presentedView = AnyView(view)
        presentationStyle = style
    }
    
    func dismiss() {
        presentedView = nil
    }
    
    func showAlert(_ model: AlertModel) {
        present(AlertView(model: model), style: .fullScreen)
    }
    
    func popToRoot() {
        path.removeAll()
    }
}
