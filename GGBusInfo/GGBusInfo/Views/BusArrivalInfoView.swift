//
//  BusArrivalInfoView.swift
//  GgBus
//
//  Created by sumin on 2/3/25.
//

import SwiftUI
import RealmSwift

/// headerView의 위치 값을 전달하기 위한 PreferenceKey
struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct BusArrivalInfoView: View {
    let stationId: String
    let stationName: String
    let mobileNo: String
    
    @State private var busArrivals: [BusArrival] = []
    @State private var timer: Timer?
    @State private var updateTimer: Timer?
    @State private var showNavigationBarFavorite = false  // 스크롤 상태에 따라 즐겨찾기 버튼 위치 전환
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var favoriteStationManager: FavoriteStationManager
    
    var isFavoriteStation: Bool {
        favoriteStationManager.isFavoriteStation(stationId: stationId)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                headerView
                ForEach(0..<busArrivals.count, id: \.self) { index in
                    busArrivalRow(arrival: busArrivals[index])
                    if index < busArrivals.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 0)
        }
        .background(AppTheme.backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationTitle(stationName)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                AnyView(
                    Group {
                        if showNavigationBarFavorite {
                            Button(action: {
                                toggleFavoriteStation()
                            }) {
                                Image(systemName: isFavoriteStation ? "star.fill" : "star")
                                    .foregroundColor(isFavoriteStation ? AppTheme.accentColor : .gray)
                                    .font(.system(size: 20))
                            }
                        } else {
                            EmptyView()
                        }
                    }
                )
            }
        }
        .onAppear {
            // 네비게이션 바의 외형 설정
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.gray
            appearance.shadowColor = .clear    // 구분선(섀도우) 제거
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.white  // 기본 타이틀 폰트 색상
            ]
            appearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor.white  // large 타이틀 폰트 색상
            ]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            startUpdateTimer()
            startCountdownTimer()
            fetchData()
        }
        .onDisappear {
            updateTimer?.invalidate()
            timer?.invalidate()
        }
    }
    
    /// 상단 헤더 뷰: mobileNo와 (스크롤 상태에 따라) 즐겨찾기 버튼 포함, 어두운 회색 배경 적용
    var headerView: some View {
        VStack(spacing: 0) {
            // headerView의 위치를 추적하기 위한 GeometryReader
            GeometryReader { geo in
                Color.clear
                    .preference(key: ViewOffsetKey.self, value: geo.frame(in: .global).minY)
            }
            .frame(height: 0)
            
            // 전체 너비를 채우도록 frame 수정
            VStack {
                VStack {
                    Text(mobileNo)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                    // headerView가 화면에 보일 때는 오른쪽에 즐겨찾기 버튼 표시
                    if !showNavigationBarFavorite {
                        Button(action: {
                            toggleFavoriteStation()
                        }) {
                            Image(systemName: isFavoriteStation ? "star.fill" : "star")
                                .foregroundColor(isFavoriteStation ? AppTheme.accentColor : .gray)
                                .font(.system(size: 20))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity)   // 화면 전체 너비로 확장
            .background(Color(.gray))
        }
        .onPreferenceChange(ViewOffsetKey.self) { value in
            withAnimation {
                showNavigationBarFavorite = value < 0
            }
        }
    }
    
    func busArrivalRow(arrival: BusArrival) -> some View {
        HStack {
            Button(action: {
                toggleBusRouteFavorite(routeId: arrival.routeId, routeName: arrival.routeName)
            }) {
                Image(systemName: favoriteStationManager.isFavoriteBusRoute(stationId: stationId, routeId: arrival.routeId) ? "star.fill" : "star")
                    .foregroundColor(favoriteStationManager.isFavoriteBusRoute(stationId: stationId, routeId: arrival.routeId) ? AppTheme.accentColor : .gray)
                    .font(.system(size: 25))
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("\(arrival.routeName)")
                        .font(.headline)
                    
                    Text("\(arrival.routeDestName) 방면")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                DualTimeDisplayView(
                    seconds1: arrival.predictTimeSec1,
                    seconds2: arrival.predictTimeSec2
                )
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(5)
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
