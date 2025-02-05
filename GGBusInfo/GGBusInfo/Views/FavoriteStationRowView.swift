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
            // 정류장 이름
            Text("\(station.stationName)")
                .font(.headline)
            
            // 정류장이름과 노선을 구분하는 Divider (좌우 여백 없음)
            Divider()
                .padding(.horizontal, 0)
            
            // 즐겨찾기된 각 버스 노선과 도착정보 표시
            ForEach(Array(station.busRoutes.enumerated()), id: \.element.routeId) { index, route in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(route.routeName)")
                            .font(.subheadline)
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
                    
                    // 마지막 노선이 아니라면 노선과 노선 사이에 Divider 추가
                    if index < station.busRoutes.count - 1 {
                        Divider()
                    }
                }
            }
        }
        // 전체 정류장 박스에 대해 좌우에 여백을 주어 다른 정류장 박스와 분리
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(8)
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
