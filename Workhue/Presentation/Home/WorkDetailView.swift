//
//  WorkDetailView.swift
//  Workhue
//
//  Created by 김서연 on 4/26/26.
//
import SwiftUI

struct WorkDetailView: View {
    let workModel: DayWorkModel
    @State private var text = ""
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(headerType: .modal(workModel.date.formatted(
                .dateTime
                .month()
                .day()
                .locale(Locale(identifier: "ko_KR"))
            )))
            .frame(height: 56)
            WorkTimeLineView(checkIn: workModel.startTime, checkOut: workModel.endTime, workState: workModel.status)
                .frame(height: 120)
            HStack {
                Text("목표")
                    .font(.system(size: FontSize.lg, weight: .semibold))
                    .foregroundStyle(Color.System.pointText)
                Spacer()
                Button("수정") {
                    
                }
                .font(.system(size: FontSize.md))
                .underline()
                .foregroundStyle(.gray)
            }
            WorkDetailCheckList(list: workModel.checkList)
            HStack {
                Text("회고")
                    .font(.system(size: FontSize.lg, weight: .semibold))
                    .foregroundStyle(Color.System.pointText)
                Spacer()
                Button("수정") {
                    
                }
                .font(.system(size: FontSize.md))
                .underline()
                .foregroundStyle(.gray)
            }
            VStack(alignment: .trailing, spacing: 4) {
                ZStack(alignment: .center) {
                    TextEditor(text: $text)
                        .onChange(of: text) { newValue in
                            if newValue.count > 300 {
                                text = String(newValue.prefix(300))
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                        .foregroundStyle(Color.System.text)
                    if text.isEmpty {
                        Text("오늘 하루를 기록해보세요")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                    }
                }
                .frame(height: 200)
                
                Text("\(text.count)/300")
                    .font(.system(size: FontSize.xs))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            
        }.padding(20)
            .background(Color.System.background)
    }
}

struct WorkDetailCheckList: View {
    let list: [WorkCheckList]
    var body: some View {
        if list.count == 0 {
            Text("아직 목표가 없어요")
                .font(.system(size: FontSize.lg))
                .foregroundStyle(.secondary)
        } else {
            
        }
    }
}

#Preview {
    WorkDetailView(workModel: DayWorkModel(id: "", date: Date(), status: .afterWorking, startTime: Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date()) ?? Date(), endTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()))
}
