//
//  AlertView.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import SwiftUI

// Common/Alert/AlertView.swift
struct AlertView: View {
    let model: AlertModel
    
    init(model: AlertModel) {
        self.model = model
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 18) {
                if !model.title.isEmpty {
                    Text(model.title)
                        .font(.system(size: FontSize.lg, weight: .semibold))
                }
                
                if !model.message.isEmpty {
                    Text(model.message)
                        .font(.system(size: FontSize.md))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                
                if let view = model.customView {
                    view
                }
                
                HStack(spacing: 12) {
                    if !model.cancelTitle.isEmpty {
                        Button(model.cancelTitle) {
                            NavigationRouter.shared.dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(model.cancelbackgroundColor)
                        .foregroundStyle(model.cancelforgroundColor ?? .black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(model.confirmTitle) {
                        model.confirmAction?()
                        NavigationRouter.shared.dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(model.confirmbackgroundColor)
                    .foregroundStyle(model.confirmforgroundColor ?? .white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(24)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4))
        .ignoresSafeArea()
    }
}

struct AlertModel {
    let title: String
    let message: String
    let customView: AnyView?
    let confirmTitle: String
    let cancelTitle: String
    let confirmAction: (() -> Void)?
    let confirmforgroundColor: Color?
    let cancelforgroundColor: Color?
    let confirmbackgroundColor: Color?
    let cancelbackgroundColor: Color?
    
    init(
        title: String,
        message: String,
        customView: AnyView? = nil,
        confirmTitle: String = "확인",
        cancelTitle: String = "취소",
        confirmAction: (() -> Void)? = nil,
        confirmforgroundColor: Color? = .white,
        confirmbackgroundColor: Color? = .blue,
        cancelforgroundColor: Color? = .black,
        cancelbackgroundColor: Color? = .gray
    ) {
        self.title = title
        self.message = message
        self.customView = customView
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.confirmAction = confirmAction
        self.confirmforgroundColor = confirmforgroundColor
        self.confirmbackgroundColor = confirmbackgroundColor
        self.cancelforgroundColor = cancelforgroundColor
        self.cancelbackgroundColor = cancelbackgroundColor
    }
}

#Preview {
    AlertView( model:
        AlertModel(title: "정말 삭제할까요?",
        message: "삭제된 데이터는 복구할 수 없어요.",
        confirmTitle: "삭제")
    )
}
