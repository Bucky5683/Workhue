//
//  MenuButton.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import SwiftUI

struct MenuButton: View {
    let hasNotification: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.black)
                
                if hasNotification {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 4, y: -4)
                }
            }
        }
    }
}
