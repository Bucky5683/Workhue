import SwiftUI
import Combine
import ComposableArchitecture

enum Route: Hashable {
    case dayDetail(DayWorkModel)
    case checkIn
    case checkOut(DayWorkModel)        // ← 추가
    case checkOutReview(DayWorkModel)  // ← 추가
    case settings
    case unlockedColors
    case appTheme
    case subscription
}

enum PresentationStyle {
    case fullScreen
    case sheet
    case popover
    case overFullScreen
}

@MainActor
final class NavigationRouter: ObservableObject {
    static let shared = NavigationRouter()
    private init() {}

    @Published var presentedView: AnyView? = nil
    @Published var presentationStyle: PresentationStyle = .fullScreen
    @Published var path: [Route] = []

    private var colorPickerCompletion: ((WorkColor, String?) -> Void)?
    
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
        guard !path.isEmpty else { return }
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
    
    func presentColorPicker(
            aiColor: WorkColor,
            onConfirm: @escaping (WorkColor, String?) -> Void
        ) {
            colorPickerCompletion = onConfirm

            present(
                ColorPickerView(
                    store: Store(
                        initialState: ColorPickerFeature.State(
                            aiColor: aiColor,
                            selectedColor: aiColor
                        )
                    ) {
                        ColorPickerFeature()
                    },
                    onConfirm: { [weak self] selectedColor, customHex in
                        self?.colorPickerCompletion?(selectedColor, customHex)
                        self?.dismiss()
                    },
                    onCancel: { [weak self] in
                        self?.dismiss()
                    }
                ),
                style: .fullScreen
            )
        }
}
