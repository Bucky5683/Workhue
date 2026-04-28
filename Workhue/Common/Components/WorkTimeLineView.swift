//
//  WorkTimeLineView.swift
//  Workhue
//
//  Created by 김서연 on 4/26/26.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct WorkTimeLineView: View {
    let checkIn: Date?
    let checkOut: Date?
    let workState: WorkStatus
    
    private let maxHours: Double = 8 * 3600 // 8시간 기준
    
    // 현재 근무 시간 (초)
    private var workedSeconds: Double {
        guard let checkIn else { return 0 }
        let end = checkOut ?? Date()
        return end.timeIntervalSince(checkIn)
    }
    
    // 근무 시간 텍스트
    private var workedTimeText: String {
        let hours = Int(workedSeconds) / 3600
        let minutes = (Int(workedSeconds) % 3600) / 60
        
        switch workState {
        case .working:
            if hours > 0 {
                return "\(hours)시간 \(minutes)분 근무 중"
            } else {
                return "\(minutes)분 근무 중"
            }
        case .afterWorking:
            if hours > 0 {
                return "\(hours)시간 \(minutes)분 근무"
            } else {
                return "\(minutes)분 근무"
            }
        case .beforeWorking:
            return "아직 근무 기록이 없어요."
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // 근무 시간 텍스트
            
            if checkIn != nil {
                GeometryReader { geo in
                    
                    VStack(spacing: 8) {
                        Text(workedTimeText)
                            .font(.system(size: FontSize.sm, weight: .medium))
                            .foregroundStyle(.secondary)
                        HStack(alignment: .center, spacing: 8) {
                            // 출근
                            VStack(spacing: 2) {
                                Text("💼").font(.system(size: FontSize.md))
                                Text("출근").font(.system(size: FontSize.xs))
                                    .foregroundStyle(Color.System.text)
                                Text(checkIn?.formatted(.dateTime.hour().minute()) ?? "")
                                    .font(.system(size: FontSize.xs, weight: .medium))
                                    .foregroundStyle(Color.System.pointText)
                            }
                            
                            // 바
                            GeometryReader { geo in
                                let ratio = min(workedSeconds / maxHours, 1.0)
                                let barWidth = geo.size.width * ratio
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.15))
                                        .frame(height: 10)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(width: barWidth, height: 10)
                                }
                            }
                            .frame(height: 10)
                            
                            // 퇴근/업무중
                            VStack(spacing: 2) {
                                Text(workState == .working ? "🏃‍➡️" : "🏠")
                                    .font(.system(size: FontSize.md))
                                Text(workState == .working ? "업무중" : "퇴근")
                                    .font(.system(size: FontSize.xs))
                                    .foregroundStyle(Color.System.text)
                                Text((workState == .working ? Date() : checkOut)?.formatted(.dateTime.hour().minute()) ?? "")
                                    .font(.system(size: FontSize.xs, weight: .medium))
                                    .foregroundStyle(Color.System.pointText)
                            }
                        }
                    }
                }
                .frame(height: 70)
            } else {
                Text("아직 근무 기록이 없어요.")
                    .font(.system(size: FontSize.lg))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        // 업무 중
        WorkTimeLineView(
            checkIn: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
            checkOut: nil,
            workState: .working
        )
        
        // 퇴근 완료
        WorkTimeLineView(
            checkIn: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
            checkOut: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date(),
            workState: .afterWorking
        )
        
        // 미출근
        WorkTimeLineView(
            checkIn: nil,
            checkOut: nil,
            workState: .beforeWorking
        )
    }
}
