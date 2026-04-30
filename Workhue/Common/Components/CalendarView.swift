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
    let dateModels: [DayWorkModel]
    let onSave: () -> Void

    init(dateModels: [DayWorkModel], onSave: @escaping () -> Void) {
        self.dateModels = dateModels
        self.onSave = onSave
    }

    var body: some View {
        VStack {
            VStack {
                Text(currentMonth, format: .dateTime.year())
                    .font(.system(size: FontSize.sm, weight: .regular))
                    .foregroundStyle(Color.System.pointText)
                Text(currentMonth, format: .dateTime.month())
                    .font(.system(size: FontSize.lg, weight: .regular))
                    .foregroundStyle(Color.System.pointText)
            }.padding(20)

            LazyVGrid(columns: columns) {
                ForEach(["SUN","MON","TUE","WEN","THU","FRI","SAT"], id: \.self) {
                    Text($0)
                        .font(.system(size: FontSize.sm, weight: .light))
                        .foregroundStyle($0 == "SUN" ? .red : Color.System.text)
                }
            }

            LazyVGrid(columns: columns) {
                ForEach(daysInMonth(), id: \.self) { calendarDay in
                    switch calendarDay {
                    case .empty:
                        Color.clear.aspectRatio(1, contentMode: .fit)
                    case .day(let date):
                        DayCell(
                            date: date,
                            workColor: dateModels.first {
                                Calendar.current.isDate($0.date, inSameDayAs: date)
                            }?.workColor
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            let data = dateModels.first {
                                Calendar.current.isDate($0.date, inSameDayAs: date)
                            }
                            NavigationRouter.shared.present(
                                WorkDetailView(
                                    workModel: data ?? DayWorkModel(
                                        id: date.formatted(.iso8601),
                                        date: date,
                                        status: .beforeWorking,
                                        startTime: nil,
                                        endTime: nil
                                    ),
                                    onSave: onSave
                                ),
                                style: .sheet
                            )
                        }
                    }
                }
            }
        }
        .background(Color.System.background)
        .simultaneousGesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 50 {
                        prevMonth()
                    } else if value.translation.width < -50 {
                        nextMonth()
                    }
                }
        )
    }

    func prevMonth() {
        withAnimation(.easeOut) {
            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }

    func nextMonth() {
        withAnimation(.easeOut) {
            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }

    func daysInMonth() -> [CalendarDay] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        var components = calendar.dateComponents([.year, .month], from: currentMonth)
        components.day = 1
        components.hour = 12
        components.minute = 0
        components.second = 0

        let firstDay = calendar.date(from: components)!
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1

        var days: [CalendarDay] = (0..<firstWeekday).map { .empty($0) }
        for day in 0..<range.count {
            let date = calendar.date(byAdding: .day, value: day, to: firstDay)!
            days.append(.day(date))
        }
        return days
    }
}

struct DayCell: View {
    let date: Date
    var workColor: WorkColor?

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.clear)
            .overlay {
                // 그라디언트 / 단색 / 오늘 기본색 분기
                if let workColor = workColor {
                    if let gradient = workColor.gradient {
                        RoundedRectangle(cornerRadius: 8).fill(gradient)
                    } else {
                        RoundedRectangle(cornerRadius: 8).fill(workColor.color)
                    }
                } else if Calendar.current.isDateInToday(date) {
                    RoundedRectangle(cornerRadius: 8).fill(Color.System.sub)
                }
            }
            .overlay {
                Text(date.day)
                    .font(.system(size: FontSize.sm, weight: .light))
                    .foregroundStyle(Color.System.text)
            }
            .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    CalendarView(dateModels: [], onSave: {})
}
