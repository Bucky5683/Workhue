import SwiftUI

struct WorkDetailView: View {
    let workModel: DayWorkModel
    let onSave: (() -> Void)?
    // 상태 체크 변수 추가
    private var isEditable: Bool {
        workModel.status != .beforeWorking
    }
    
    @StateObject private var viewModel: WorkDetailViewModel
    
    init(workModel: DayWorkModel, onSave: (() -> Void)? = nil) {
        self.workModel = workModel
        self.onSave = onSave
        let repo = DayWorkRepositoryImpl()
        let saveUseCase = SaveDayWorkUseCase(repository: repo)
        _viewModel = StateObject(wrappedValue: WorkDetailViewModel(
            workModel: workModel,
            saveUseCase: saveUseCase
        ))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(headerType: .modal(workModel.date.formatted(
                .dateTime
                    .month()
                    .day()
                    .locale(Locale(identifier: "ko_KR"))
            )))
            .frame(height: 56)
            
            WorkTimeLineView(
                checkIn: workModel.startTime,
                checkOut: workModel.endTime,
                workState: workModel.status
            )
            .frame(height: 120)
            
            HStack {
                Text("목표")
                    .font(.system(size: FontSize.lg, weight: .semibold))
                    .foregroundStyle(Color.System.pointText)
                Spacer()
                Button("수정") { }
                    .font(.system(size: FontSize.md))
                    .underline()
                    .foregroundStyle(.gray)
                    .disabled(!isEditable)
                    .opacity(isEditable ? 1 : 0.3)
            }
            
            WorkDetailCheckList(list: workModel.checkList)
            
            HStack {
                Text("회고")
                    .font(.system(size: FontSize.lg, weight: .semibold))
                    .foregroundStyle(Color.System.pointText)
                Spacer()
                Button("저장") {
                    viewModel.saveRememrance { onSave?() }
                }
                .font(.system(size: FontSize.md))
                .underline()
                .foregroundStyle(.gray)
                .disabled(!isEditable)
                .opacity(isEditable ? 1 : 0.3)
            }
            
            VStack(alignment: .trailing, spacing: 4) {
                ZStack(alignment: .center) {
                    TextEditor(text: $viewModel.remembrance)
                        .onChange(of: viewModel.remembrance) { newValue in
                            if newValue.count > 300 {
                                viewModel.remembrance = String(newValue.prefix(300))
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                        .foregroundStyle(Color.System.text)
                        .disabled(!isEditable)  // ← 추가
                    if viewModel.remembrance.isEmpty {
                        Text("오늘 하루를 기록해보세요")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                    }
                }
                .frame(height: 200)
                
                Text("\(viewModel.remembrance.count)/300")
                    .font(.system(size: FontSize.xs))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.System.background)
        .disabled(viewModel.isLoading)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
}

struct WorkDetailCheckList: View {
    let list: [WorkCheckList]
    var body: some View {
        if list.isEmpty {
            Text("아직 목표가 없어요")
                .font(.system(size: FontSize.lg))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    WorkDetailView(workModel: DayWorkModel(
        id: "",
        date: Date(),
        status: .afterWorking,
        startTime: Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date()),
        endTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())
    ))
}
