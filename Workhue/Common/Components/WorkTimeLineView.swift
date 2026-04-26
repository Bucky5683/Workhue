//
//  WorkTimeLineView.swift
//  Workhue
//
//  Created by 김서연 on 4/26/26.
//

import SwiftUI
import Combine
import WeatherKit
import CoreLocation

struct WorkTimeLineView: View {
    let checkIn: Date?
    let checkOut: Date?
    let workState: WorkStatus
    
    @State private var sunrise: Date = Date()
    @State private var sunset: Date = Date()
    
    private let weatherService = WeatherService.shared
    private let locationManager = CLLocationManager()
    
    var body: some View {
        // 바 구현
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                BaseBar()
                WorkRangeBar(
                    geo: geo,
                    checkIn: checkIn,
                    checkOut: checkOut,
                    xPosition: xPosition
                )
                Icons(
                    geo: geo,
                    sunrise: sunrise,
                    sunset: sunset,
                    checkIn: checkIn,
                    checkOut: checkOut,
                    xPosition: xPosition
                )
                if workState == .working {
                    RunningPersonView(
                        geo: geo,
                        sunrise: sunrise,
                        sunset: sunset
                    )
                }
            }
            .frame(height: 44)
            .task {
                await fetchSunTimes()
            }
        }
    }
    
    private func fetchSunTimes() async {
        // 위치 권한 필요
        let location = CLLocation(
            latitude: locationManager.location?.coordinate.latitude ?? 37.5665,
            longitude: locationManager.location?.coordinate.longitude ?? 126.9780
        )
        
        do {
            // 시뮬레이터용 목데이터
            #if targetEnvironment(simulator)
            sunrise = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date()) ?? Date()
            sunset = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date()
            #else
            // 실기기 WeatherKit 호출
            let weather = try await weatherService.weather(for: location)
            sunrise = weather.dailyForecast.first?.sun.sunrise ?? Date()
            sunset = weather.dailyForecast.first?.sun.sunset ?? Date()
            #endif
        } catch {
            print("WeatherKit error: \(error)")
        }
    }
    
    // 일출~일몰 전체 범위에서 특정 시간의 x 위치 계산
    private func xPosition(for date: Date, in width: CGFloat) -> CGFloat {
        let total = sunset.timeIntervalSince(sunrise)
        let offset = date.timeIntervalSince(sunrise)
        let ratio = max(0, min(1, offset / total))
        return width * ratio
    }
}
// MARK: - WorkRangeBar
struct WorkRangeBar: View {
    let geo: GeometryProxy
    let checkIn: Date?
    let checkOut: Date?
    let xPosition: (Date, CGFloat) -> CGFloat
    
    var body: some View {
        if let checkIn {
            let startX = xPosition(checkIn, geo.size.width)
            let endX = checkOut.map { xPosition($0, geo.size.width) } ?? xPosition(Date(), geo.size.width)
            let width = max(0, endX - startX)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.green.opacity(0.5))
                .frame(width: width, height: 6)
                .offset(x: startX)
                .padding(.top, 12)
        }
    }
}

// MARK: - Icons
struct Icons: View {
    let geo: GeometryProxy
    let sunrise: Date
    let sunset: Date
    let checkIn: Date?
    let checkOut: Date?
    let xPosition: (Date, CGFloat) -> CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            // 일출
            IconPin(emoji: "☀️", label: sunrise.formatted(.dateTime.hour().minute()))
                .position(x: xPosition(sunrise, geo.size.width), y: 10)
            
            // 일몰
            IconPin(emoji: "🌕", label: sunset.formatted(.dateTime.hour().minute()))
                .position(x: xPosition(sunset, geo.size.width), y: 10)
            
            // 출근
            if let checkIn {
                IconPin(emoji: "💼", label: checkIn.formatted(.dateTime.hour().minute()))
                    .position(x: xPosition(checkIn, geo.size.width), y: 32)
            }
            
            // 퇴근
            if let checkOut {
                IconPin(emoji: "🏠", label: checkOut.formatted(.dateTime.hour().minute()))
                    .position(x: xPosition(checkOut, geo.size.width), y: 32)
            }
        }
    }
}
// MARK: - BaseBar
struct BaseBar: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 6)
            .frame(maxWidth: .infinity)
            .padding(.top, 12) // 아이콘 공간 확보
    }
}

// MARK: - IconPin
struct IconPin: View {
    let emoji: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(emoji)
                .font(.system(size: 12))
            Text(label)
                .font(.system(size: FontSize.xs))
                .foregroundStyle(.secondary)
        }
    }
}

struct RunningPersonView: View {
    let geo: GeometryProxy
    let sunrise: Date
    let sunset: Date
    
    @State private var currentTime: Date = Date()
    
    // 1초마다 현재 시각 업데이트
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var xPos: CGFloat {
        let total = sunset.timeIntervalSince(sunrise)
        let offset = currentTime.timeIntervalSince(sunrise)
        let ratio = max(0, min(1, offset / total))
        return geo.size.width * ratio
    }
    
    var body: some View {
        Text("🏃‍➡️")
            .font(.system(size: 16))
            .position(x: xPos, y: 0)
            .animation(.linear(duration: 1), value: xPos)
            .onReceive(timer) { time in
                currentTime = time
            }
    }
}

#Preview {
    WorkTimeLineView(checkIn: Date(), checkOut: nil, workState: .working)
}
