import SwiftUI
import SwiftData

struct WorkDetailView: View {
    let workModel: DayWorkModel
    let onSave: (() -> Void)?

    @StateObject private var viewModel: WorkDetailViewModel

    init(workModel: DayWorkModel, onSave: (() -> Void)? = nil) {
        self.workModel = workModel
        self.onSave = onSave
        let repo = DayWorkRepositoryImpl(context: SwiftDataManager.shared.context)  // 수정
        let saveUseCase = SaveDayWorkUseCase(repository: repo)
        _viewModel = StateObject(wrappedValue: WorkDetailViewModel(
            workModel: workModel,
            saveUseCase: saveUseCase
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(headerType: .modal(workModel.date.formatted(
                .dateTime.month().day()
                .locale(Locale(identifier: "ko_KR"))
            )))
            .frame(height: 56)
            .padding(.horizontal, 20)

            List {
                // WorkTimeLine
                WorkTimeLineView(
                    checkIn: workModel.startTime,
                    checkOut: workModel.endTime,
                    workState: workModel.status
                )
                .frame(height: 120)
                .listRowBackground(Color.System.background)
                .listRowSeparator(.hidden)

                // 목표 헤더
                Text("목표")
                    .font(.system(size: FontSize.lg, weight: .semibold))
                    .foregroundStyle(Color.System.pointText)
                    .listRowBackground(Color.System.background)
                    .listRowSeparator(.hidden)

                // 목표 셀
                ForEach($viewModel.goals) { $goal in
                    GoalRowCell(
                        goal: $goal,
                        isEditable: viewModel.isEditable,
                        onToggle: { viewModel.toggleGoal(id: goal.id) },
                        onEdit: { viewModel.editGoal(id: goal.id) },
                        onCommit: { viewModel.commitGoal(id: goal.id) }
                    )
                    .listRowBackground(Color.System.background)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                    .swipeActions(edge: .trailing) {
                        if viewModel.isEditable {
                            Button(role: .destructive) {
                                viewModel.deleteGoal(id: goal.id)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                    }
                }

                // 목표 추가 버튼
                if viewModel.isEditable {
                    Button {
                        viewModel.addGoal()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("목표 추가")
                        }
                        .font(.system(size: FontSize.md))
                        .foregroundStyle(Color.System.main)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.System.sub.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .listRowBackground(Color.System.background)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                }

                // 회고 헤더
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
                    .disabled(!viewModel.isEditable)
                    .opacity(viewModel.isEditable ? 1 : 0.3)
                }
                .listRowBackground(Color.System.background)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))

                // 회고 입력
                VStack(alignment: .trailing, spacing: 4) {
                    ZStack(alignment: .center) {
                        TextEditor(text: $viewModel.remembrance)
                            .onChange(of: viewModel.remembrance) { _, newValue in
                                if newValue.count > 300 {
                                    viewModel.remembrance = String(newValue.prefix(300))
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .background(.clear)
                            .foregroundStyle(Color.System.text)
                            .disabled(!viewModel.isEditable)
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
                .listRowBackground(Color.System.background)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(Color.System.background)
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.2).ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
    }
}

// MARK: - GoalRowCell
struct GoalRowCell: View {
    @Binding var goal: GoalItem
    let isEditable: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onCommit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button {
                onToggle()
            } label: {
                RoundedRectangle(cornerRadius: 4)
                    .fill(goal.isDone ? Color.System.main : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.System.main, lineWidth: 1.5)
                    )
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .opacity(goal.isDone ? 1 : 0)
                    )
                    .frame(width: 20, height: 20)
            }
            .disabled(!isEditable)

            if goal.isEditing {
                TextField("목표를 입력하세요", text: $goal.content)
                    .font(.system(size: FontSize.md))
                    .foregroundStyle(Color.System.text)
                    .onSubmit { onCommit() }
                    .submitLabel(.done)
            } else {
                Text(goal.content)
                    .font(.system(size: FontSize.md))
                    .foregroundStyle(goal.isDone ? .secondary : Color.System.text)
                    .strikethrough(goal.isDone)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isEditable {
                    Button("수정") { onEdit() }
                        .font(.system(size: FontSize.sm))
                        .underline()
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color.System.sub.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
