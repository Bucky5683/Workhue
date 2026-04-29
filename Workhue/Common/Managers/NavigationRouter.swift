import SwiftUI
import Combine

enum Route: Hashable {
    case dayDetail(DayWorkModel)
    case checkIn
    case checkOut(DayWorkModel)        // ← 추가
    case checkOutReview(DayWorkModel)  // ← 추가
    case colorPicker
    case settings
}

enum PresentationStyle {
    case fullScreen
    case sheet
    case popover
    case overFullScreen
}

final class NavigationRouter: ObservableObject {
    static let shared = NavigationRouter()
    private init() {}

    @Published var presentedView: AnyView? = nil
    @Published var presentationStyle: PresentationStyle = .fullScreen
    @Published var path: [Route] = []

    func push(_ route: Route) {
        path.append(route)
    }

    func close() {
        if presentedView != nil {
            dismiss()
        } else {
            pop()
        }
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
