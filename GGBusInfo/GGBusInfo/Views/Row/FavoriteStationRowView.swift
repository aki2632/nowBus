//
//  FavoriteStationRowView.swift
//  GGBusInfo
//
//  Created by sumin on 2/3/25.
//

import SwiftUI
import RealmSwift

struct FavoriteStationRowView: View {
    @ObservedRealmObject var station: FavoriteStation  // Realm 객체 변경 감지를 위해 변경
    @State private var busArrivals: [BusArrival] = []
    @State private var timer: Timer?
    @State private var updateTimer: Timer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading) {
                Text(station.stationName)
                    .font(.headline)
                Text(station.mobileNo)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding()
                
            Divider()
                .padding(.horizontal, 0)
            
            // 버스 즐겨찾기가 없다면 안내 문구 표시
            if station.busRoutes.isEmpty {
                Text("버스 즐겨찾기를 추가해주세요")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding()
            } else {
                ForEach(Array(station.busRoutes.enumerated()), id: \.element.routeId) { index, route in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(route.routeName)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if let arrival = busArrivals.first(where: { $0.routeId == route.routeId }) {
                                DualTimeDisplayView(
                                    seconds1: arrival.predictTimeSec1,
                                    seconds2: arrival.predictTimeSec2
                                )
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Spacer(minLength: 60)
                        }
                        .padding()
                        
                        if index < station.busRoutes.count - 1 { // 마지막 노선이 아닌 경우에만 Divider 추가
                            Divider()
                                .padding(.leading)
                        }
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
        // 새로고침 버튼의 알림을 수신하면 API 정보를 다시 요청합니다.
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("RefreshBusArrival"))) { _ in
            fetchData()
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
    
    func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 180, repeats: true) { _ in
            self.fetchData()
        }
    }
}
