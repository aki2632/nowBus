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
    @State private var showNavigationBarFavorite = false
    @State private var showUnfavoriteConfirmation = false
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var favoriteStationManager: FavoriteStationManager
    
    var isFavoriteStation: Bool {
        favoriteStationManager.isFavoriteStation(stationId: stationId)
    }
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // 분리한 헤더 컴포넌트 (다크모드 색상 적용)
                    BusArrivalHeaderView(
                        mobileNo: mobileNo,
                        isFavoriteStation: isFavoriteStation,
                        toggleFavorite: toggleFavoriteStation,
                        showNavigationBarFavorite: $showNavigationBarFavorite
                    )
                    
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
            
            // 우측 하단 새로고침 버튼 (RefreshButtonView 사용)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    RefreshButtonView(action: fetchData)
                        .padding()
                }
            }
        }
        .navigationTitle(stationName)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // 네비게이션 바 좌측 뒤로가기 버튼 (다크모드 색상 적용)
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.customWhite)
                        .font(.system(size: 20, weight: .medium))
                }
            }
            // 네비게이션 바 우측 즐겨찾기 버튼 (헤더 스크롤 시 노출)
            ToolbarItem(placement: .navigationBarTrailing) {
                Group {
                    if showNavigationBarFavorite {
                        Button(action: toggleFavoriteStation) {
                            Image(systemName: isFavoriteStation ? "star.fill" : "star")
                                .foregroundColor(isFavoriteStation ? AppTheme.accentColor : .gray)
                                .font(.system(size: 20))
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showUnfavoriteConfirmation) {
            Alert(
                title: Text("즐겨찾기 해제"),
                message: Text("정말로 즐겨찾기를 해제하시겠습니까?\n 함께 저장한 버스 즐겨찾기도 삭제됩니다."),
                primaryButton: .destructive(Text("해제하기")) {
                    favoriteStationManager.removeFavoriteStation(stationId: stationId)
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
        .onAppear {
            // 네비게이션 바 외형 설정 (다크모드에 맞는 커스텀 색상 적용)
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(AppTheme.customGray)
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.customWhite)]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppTheme.customWhite)]
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
    
    /// 버스 도착 정보 행: 즐겨찾기 버튼 및 도착 시간 정보를 표시 (다크모드 색상 적용)
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
        .background(AppTheme.customBlack)
        .cornerRadius(5)
    }
    
    /// API 호출: 버스 도착 정보 데이터를 불러오고 정렬합니다.
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
    
    /// 매초마다 버스 도착 시간 카운트다운을 업데이트합니다.
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
    
    /// 일정 주기로 데이터를 업데이트합니다.
    func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
            self.fetchData()
        }
    }
    
    /// 정류장 즐겨찾기 토글: 이미 즐겨찾기된 경우 알림을 표시합니다.
    func toggleFavoriteStation() {
        if isFavoriteStation {
            showUnfavoriteConfirmation = true
        } else {
            favoriteStationManager.addFavoriteStation(stationId: stationId, stationName: stationName, mobileNo: mobileNo)
        }
    }
    
    /// 버스 노선 즐겨찾기 토글: 즐겨찾기 상태에 따라 추가 또는 제거하며, 정렬을 업데이트합니다.
    func toggleBusRouteFavorite(routeId: Int, routeName: String) {
        if favoriteStationManager.isFavoriteBusRoute(stationId: stationId, routeId: routeId) {
            favoriteStationManager.removeFavoriteBusRoute(stationId: stationId, routeId: routeId)
        } else {
            if !favoriteStationManager.isFavoriteStation(stationId: stationId) {
                favoriteStationManager.addFavoriteStation(stationId: stationId, stationName: stationName, mobileNo: mobileNo)
            }
            favoriteStationManager.addFavoriteBusRoute(stationId: stationId, routeId: routeId, routeName: routeName)
        }
        sortBusArrivals()
    }
    
    /// 버스 도착 정보를 즐겨찾기 여부와 도착 시간을 기준으로 정렬합니다.
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
