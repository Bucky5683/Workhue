import SwiftUI

struct HomeView: View {
    let screenId: ScreenID = .home
    
    @StateObject private var viewModel: HomeViewModel = {
        let repo = DayWorkRepositoryImpl()
        let getUseCase = GetDayWorkUseCase(repository: repo)
        let saveUseCase = SaveDayWorkUseCase(repository: repo)
        return HomeViewModel(getUseCase: getUseCase, saveUseCase: saveUseCase)
    }()
    
    var body: some View {
        VStack(spacing: 10) {
            HeaderView(headerType: .home(false))
                .frame(height: 56)
            
            Rectangle()
                .frame(height: 30)
                .foregroundStyle(.clear)
            
            CalendarView(
                dateModels: viewModel.allWorks,
                onSave: {
                    viewModel.loadToday()  // ← 저장 후 캘린더 갱신
                }
            )
            
            HStack(spacing: 10) {
                Text(viewModel.currentStatus.icon)
                    .font(.system(size: FontSize.md))
                Text(viewModel.currentStatus.description)
                    .foregroundStyle(.gray)
                    .font(.system(size: FontSize.md))
                Spacer()
                Button("수정") { }
                    .underline()
                    .font(.system(size: FontSize.md))
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Button {
                switch viewModel.currentStatus {
                case .beforeWorking:
                    // 오늘 날짜일 때만 출근 가능
                    if Calendar.current.isDateInToday(viewModel.todayWork?.date ?? Date())
                        || viewModel.todayWork == nil {
                        NavigationRouter.shared.push(.checkIn)
                    }
                case .working:
                    if let work = viewModel.todayWork {
                        NavigationRouter.shared.push(.checkOut(work))
                    }
                case .afterWorking:
                    break
                }
            } label: {
                Text(viewModel.currentStatus.icon)
                    .font(.system(size: FontSize.xxl))
                    .frame(width: 72, height: 72)
                    .background(Color.System.point)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
        .padding(20)
        .background(Color.System.background)
        .disabled(viewModel.isLoading) // 로딩 중 터치 막기
        .onAppear {
            viewModel.loadToday()
        }
        
        // 로딩 오버레이
        if viewModel.isLoading {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(1.5)
        }
    }
}

#Preview {
    HomeView()
}
