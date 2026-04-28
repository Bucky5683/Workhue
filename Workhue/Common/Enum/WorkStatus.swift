//
//  WorkStatus.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

enum WorkStatus: String {
    case beforeWorking
    case working
    case afterWorking
    
    var icon: String {
        switch self {
        case .working:
            return "💼"
        case .afterWorking:
            return "🏠"
        case .beforeWorking:
            return "⏰"
        }
    }
    
    var description: String {
        switch self {
        case .beforeWorking: return "아직 출근 전이에요"
        case .working:       return "근무 중이에요"
        case .afterWorking:  return "퇴근했어요"
        }
    }
}
