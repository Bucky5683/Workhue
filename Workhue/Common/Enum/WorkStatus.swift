//
//  WorkStatus.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

enum WorkStatus {
    case working
    case notWorking
    
    var icon: String {
        switch self {
        case .working:
            return "🏠"
        case .notWorking:
            return "💼"
        }
    }
}
