//
//  FavoriteStationRowView.swift
//  GGBusInfo
//
//  Created by sumin on 2/3/25.
//

import SwiftUI
import RealmSwift

struct FavoriteStationRowView: View {
    let station: FavoriteStation
    @State private var busArrivals: [BusArrival] = []
    @State private var timer: Timer?
    @State private var updateTimer: Timer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 정류장 정보
            Text("\(station.stationName)")
                .font(.headline)
            
            // 즐겨찾기된 각 버스 노선과 도착정보 표시
            ForEach(station.busRoutes, id: \.routeId) { route in
                HStack {
                    Text("\(route.routeName)")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let arrival = busArrivals.first(where: { $0.routeId == route.routeId }) {
                        DualTimeDisplayView(
                            seconds1: arrival.predictTimeSec1,
                            seconds2: arrival.predictTimeSec2
                        )
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    } else {
                        Text("정보없음")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            fetchData()
            startUpdateTimer()
            startCountdownTimer()
        }
        .onDisappear {
            updateTimer?.invalidate()
            timer?.invalidate()
        }
    }
    
    func fetchData() {
        BusAPIService.shared.fetchBusArrivalInfo(for: station.stationId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let arrivals):
                    self.busArrivals = arrivals
                case .failure(let error):
                    print("API 호출 오류: \(error)")
                }
            }
        }
    }
    
    // 도착시간을 "분 초 후" 형식으로 포맷팅
    func formatTime(_ seconds: Int?) -> String {
        guard var time = seconds else { return "정보없음" }
        if time > 0 { time -= 1 }
        let minutes = time / 60
        let secondsRemaining = time % 60
        return "\(minutes)분 \(secondsRemaining)초 후"
    }
    
    // 1초마다 도착시간을 감소시키는 타이머
    func startCountdownTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            for i in 0..<self.busArrivals.count {
                if let sec = self.busArrivals[i].predictTimeSec1, sec > 0 {
                    self.busArrivals[i].predictTimeSec1 = sec - 1
                }
                if let sec = self.busArrivals[i].predictTimeSec2, sec > 0 {
                    self.busArrivals[i].predictTimeSec2 = sec - 1
                }
            }
        }
    }
    
    // 15초마다 API 호출로 도착정보 갱신
    func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 180, repeats: true) { _ in
            self.fetchData()
        }
    }
}
