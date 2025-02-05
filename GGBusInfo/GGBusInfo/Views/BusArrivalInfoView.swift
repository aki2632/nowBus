//
//  BusArrivalInfoView.swift
//  GgBus
//
//  Created by sumin on 2/3/25.
//

import SwiftUI
import RealmSwift

struct BusArrivalInfoView: View {
    let stationId: String
    let stationName: String
    let mobileNo: String
    
    @State private var busArrivals: [BusArrival] = []
    @State private var timer: Timer?
    @State private var updateTimer: Timer?
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var favoriteStationManager: FavoriteStationManager
    
    var isFavoriteStation: Bool {
        favoriteStationManager.isFavoriteStation(stationId: stationId)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 만약 내부에도 즐겨찾기 버튼을 남기고 싶다면 아래 코드를 유지하세요.
                // 지금은 네비게이션 바에 즐겨찾기 버튼을 배치하므로 필요없다면 삭제 가능합니다.
                VStack {
                    Text("\(mobileNo)")
                        .font(.headline)
                }
                .padding(.horizontal)
                
                ForEach(busArrivals, id: \.routeId) { arrival in
                    BusArrivalRow(arrival: arrival)
                }
            }
            .padding()
        }
        .background(AppTheme.backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationTitle(stationName)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // 커스텀 백 버튼 (왼쪽)
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .font(.system(size: 20, weight: .medium))
                }
            }
            // 즐겨찾기 버튼 (오른쪽)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    toggleFavoriteStation()
                }) {
                    Image(systemName: isFavoriteStation ? "star.fill" : "star")
                        .foregroundColor(isFavoriteStation ? AppTheme.accentColor : .gray)
                        .font(.system(size: 20))
                }
            }
        }
        .onAppear {
            startUpdateTimer()
            startCountdownTimer()
            fetchData()
        }
        .onDisappear {
            updateTimer?.invalidate()
            timer?.invalidate()
        }
    }
    
    func BusArrivalRow(arrival: BusArrival) -> some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("\(arrival.routeName)")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        toggleBusRouteFavorite(routeId: arrival.routeId, routeName: arrival.routeName)
                    }) {
                        Image(systemName: favoriteStationManager.isFavoriteBusRoute(stationId: stationId, routeId: arrival.routeId) ? "star.fill" : "star")
                            .foregroundColor(favoriteStationManager.isFavoriteBusRoute(stationId: stationId, routeId: arrival.routeId) ? AppTheme.accentColor : .gray)
                            .font(.system(size: 25))
                    }
                }
                Text("\(arrival.routeDestName) 방면")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                DualTimeDisplayView(
                    seconds1: arrival.predictTimeSec1,
                    seconds2: arrival.predictTimeSec2
                )
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    func fetchData() {
        BusAPIService.shared.fetchBusArrivalInfo(for: stationId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let arrivals):
                    self.busArrivals = arrivals
                    self.sortBusArrivals()
                case .failure(let error):
                    print("API 호출 오류: \(error)")
                }
            }
        }
    }
    
    func formatTime(_ seconds: Int?) -> String {
        guard var timeInSeconds = seconds else { return "정보없음" }
        if timeInSeconds > 0 { timeInSeconds -= 1 }
        let minutes = timeInSeconds / 60
        let secondsRemaining = timeInSeconds % 60
        return "\(minutes)분 \(secondsRemaining)초 후"
    }
    
    func startCountdownTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            for i in 0..<self.busArrivals.count {
                if let sec1 = self.busArrivals[i].predictTimeSec1, sec1 > 0 {
                    self.busArrivals[i].predictTimeSec1 = sec1 - 1
                }
                if let sec2 = self.busArrivals[i].predictTimeSec2, sec2 > 0 {
                    self.busArrivals[i].predictTimeSec2 = sec2 - 1
                }
            }
        }
    }
    
    func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
            self.fetchData()
        }
    }
    
    func toggleFavoriteStation() {
        if isFavoriteStation {
            favoriteStationManager.removeFavoriteStation(stationId: stationId)
        } else {
            favoriteStationManager.addFavoriteStation(stationId: stationId, stationName: stationName, mobileNo: mobileNo)
        }
    }
    
    func toggleBusRouteFavorite(routeId: Int, routeName: String) {
        if favoriteStationManager.isFavoriteBusRoute(stationId: stationId, routeId: routeId) {
            favoriteStationManager.removeFavoriteBusRoute(stationId: stationId, routeId: routeId)
        } else {
            favoriteStationManager.addFavoriteBusRoute(stationId: stationId, routeId: routeId, routeName: routeName)
        }
        sortBusArrivals()
    }
    
    func sortBusArrivals() {
        busArrivals.sort { arrival1, arrival2 in
            let isFav1 = favoriteStationManager.isFavoriteBusRoute(stationId: stationId, routeId: arrival1.routeId)
            let isFav2 = favoriteStationManager.isFavoriteBusRoute(stationId: stationId, routeId: arrival2.routeId)
            if isFav1 && !isFav2 {
                return true
            } else if !isFav1 && isFav2 {
                return false
            }
            return (arrival1.predictTimeSec1 ?? 0) < (arrival2.predictTimeSec1 ?? 0)
        }
    }
}
