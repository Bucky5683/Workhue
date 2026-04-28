//
//  HeaderView.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import SwiftUI

struct HeaderView: View {
    let headerType: HeaderType
    
    var body: some View {
        Group {
            switch headerType {
            case .home(let noti):
                HStack(spacing: 10) {
                    Spacer()
                    MenuButton(hasNotification: noti) {
                        NavigationRouter.shared.push(.settings)
                    }
                    .frame(maxHeight: .infinity)
                }
            case .back(let title):
                HStack(spacing: 10) {
                    Button {
                        NavigationRouter.shared.pop()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.System.text)
                            .frame(maxHeight: .infinity)
                    }
                    .frame(maxHeight: .infinity)
                    if !title.isEmpty {
                        Text(title)
                            .font(.system(size: FontSize.xxl, weight: .semibold))
                            .foregroundStyle(Color.System.pointText)
                            .frame(maxHeight: .infinity)
                    }
                    Spacer()
                }
            case .modal(let title):
                HStack(spacing: 10) {
                    if !title.isEmpty {
                        Text(title)
                            .font(.system(size: FontSize.xxl, weight: .semibold))
                            .foregroundStyle(Color.System.pointText)
                            .frame(maxHeight: .infinity)
                    }
                    Spacer()
                    Button {
                        NavigationRouter.shared.pop()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.System.text)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
        }
    }
}

extension HeaderView {
    enum HeaderType {
        case home(Bool)
        case back(String)
        case modal(String)
    }
}

#Preview {
    HeaderView(headerType: .back("Ho"))
}
