//
//  ContentView.swift
//  GgBus
//
//  Created by sumin on 2/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var favoriteStationManager = FavoriteStationManager()
    @State private var selectedTab = 1
    
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
            
            Text("설정")
                .tabItem {
                    Label("설정", systemImage: "gear")
                }
                .tag(2)
        }
        .environmentObject(favoriteStationManager)
        .accentColor(AppTheme.primaryColor)
    }
}
