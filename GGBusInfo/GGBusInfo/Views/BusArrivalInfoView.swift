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
    
    // 새로 추가한 상태 변수
    @State private var rotation: Double = 0
    @State private var isAnimating = false
    
    // 즐겨찾기 해제 확인 팝업을 위한 상태 변수 (추가됨)
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
            
            // 하단 우측 새로고침 버튼
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        fetchData()
                        guard !isAnimating else { return }
                        isAnimating = true
                        rotation += 720
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isAnimating = false
                        }
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 35))
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .rotationEffect(.degrees(rotation))
                            .animation(.linear(duration: 1), value: rotation)
                    }
                    .padding()
                }
            }
        }
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
                Group {
                    if showNavigationBarFavorite {
                        Button(action: {
                            toggleFavoriteStation()
                        }) {
                            Image(systemName: isFavoriteStation ? "star.fill" : "star")
                                .foregroundColor(isFavoriteStation ? AppTheme.accentColor : .gray)
                                .font(.system(size: 20))
                        }
                    }
                }
            }
        }
        // 즐겨찾기 해제 시 확인 팝업 추가 (추가됨)
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
            // 네비게이션 바의 외형 설정
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.gray
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
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
    
    /// 상단 헤더 뷰 (스크롤 상태에 따라 즐겨찾기 버튼 포함)
    var headerView: some View {
        VStack(spacing: 0) {
            VStack {
                Text(mobileNo)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
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
        .frame(maxWidth: .infinity)
        .background(Color(.gray))
        // 스크롤에 따른 오프셋 측정
        .background(GeometryReader { proxy -> Color in
            let offset = proxy.frame(in: .global).minY
            DispatchQueue.main.async {
                withAnimation {
                    showNavigationBarFavorite = offset < -100
                }
            }
            return Color.clear
        })
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
    
    // 기존 코드를 유지하면서 즐겨찾기 해제 시 확인 팝업을 띄우도록 수정 (수정됨)
    func toggleFavoriteStation() {
        if isFavoriteStation {
            showUnfavoriteConfirmation = true
        } else {
            favoriteStationManager.addFavoriteStation(stationId: stationId, stationName: stationName, mobileNo: mobileNo)
        }
    }
    
    func toggleBusRouteFavorite(routeId: Int, routeName: String) {
        if favoriteStationManager.isFavoriteBusRoute(stationId: stationId, routeId: routeId) {
            favoriteStationManager.removeFavoriteBusRoute(stationId: stationId, routeId: routeId)
        } else {
            // 정류장이 즐겨찾기에 없으면 정류장도 추가합니다.
            if !favoriteStationManager.isFavoriteStation(stationId: stationId) {
                favoriteStationManager.addFavoriteStation(stationId: stationId, stationName: stationName, mobileNo: mobileNo)
            }
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
