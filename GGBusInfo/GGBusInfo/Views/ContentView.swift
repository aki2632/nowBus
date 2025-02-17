//
//  ContentView.swift
//  GgBus
//
//  Created by sumin on 2/3/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        // 탭바 배경색을 커스텀 회색으로 설정
        tabBarAppearance.backgroundColor = UIColor(AppTheme.customBlack)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        // 선택된 탭 색상
        UITabBar.appearance().tintColor = UIColor(AppTheme.primaryColor)
        // 선택되지 않은 탭 색상
        UITabBar.appearance().unselectedItemTintColor = UIColor(AppTheme.customWhite)
    }
    
    @StateObject var favoriteStationManager = FavoriteStationManager()
    @StateObject var locationManager = LocationManager()
    @State private var selectedTab = 1
    @State private var showLocationAlert = false

    var body: some View {
        TabView(selection: $selectedTab) {
            StationListView()
                .tabItem {
                    Label("정류장", systemImage: "bus.fill")
                }
                .tag(0)
            
            FavoriteView()
                .tabItem {
                    Label("즐겨찾기", systemImage: "star.fill")
                }
                .tag(1)
            
            OptionView()
                .tabItem {
                    Label("설정", systemImage: "gear")
                }
                .tag(2)
        }
        .environmentObject(favoriteStationManager)
        .accentColor(AppTheme.primaryColor)
        .onAppear {
            checkLocationStatus()
        }
        .onReceive(locationManager.$error) { _ in
            checkLocationStatus()
        }
    }
    
    func checkLocationStatus() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            locationManager.requestAuthorization()  // 수정된 부분
            showLocationAlert = false
        case .authorizedAlways, .authorizedWhenInUse:
            showLocationAlert = false
        case .denied, .restricted:
            showLocationAlert = true
        @unknown default:
            showLocationAlert = false
        }
    }
}
