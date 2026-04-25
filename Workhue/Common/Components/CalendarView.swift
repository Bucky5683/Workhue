//
//  CalendarView.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import SwiftUI

struct CalendarView: View {
    @State private var currentMonth: Date = Date()
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack {
            // 월 네비게이션
            HStack {
                Button { prevMonth() } label: {
                    Image(systemName: "chevron.left")
                }
                Text(currentMonth, format: .dateTime.year().month())
                Button { nextMonth() } label: {
                    Image(systemName: "chevron.right")
                }
            }
            
            // 요일 헤더
            LazyVGrid(columns: columns) {
                ForEach(["일","월","화","수","목","금","토"], id: \.self) {
                    Text($0).font(.caption)
                }
            }
            
            // 날짜 셀
            LazyVGrid(columns: columns) {
                ForEach(daysInMonth(), id: \.self) { date in
                    DayCell(date: date)
                        .onTapGesture {
                            NavigationRouter.shared.push(.dayDetail(date))
                        }
                }
            }
        }
    }
    
    func prevMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
    
    func loadCalendar() {
        
    }
    
    func daysInMonth() -> [Date] {
        let calendar = Calendar.current
        
        // 해당 월의 첫째 날
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        
        // 해당 월의 날짜 수
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        
        // 첫째 날의 요일 (일요일 = 0)
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        
        // 앞에 빈 날짜 채우기
        var days: [Date] = Array(repeating: Date.distantPast, count: firstWeekday)
        
        // 실제 날짜 채우기
        for day in 0..<range.count {
            let date = calendar.date(byAdding: .day, value: day, to: firstDay)!
            days.append(date)
        }
        
        return days
    }
}

struct DayCell: View {
    let date: Date
    var backgroundColor: Color = .red
    var textColor: Color = .black
    
    var body: some View {
        if date == Date.distantPast {
            Color.clear // 빈 셀
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .overlay {
                    Text(date.day)
                        .font(.system(size: FontSize.sm))
                        .foregroundStyle(textColor)
                }
                .aspectRatio(1, contentMode: .fit)
        }
    }
}

#Preview {
    CalendarView()
}
