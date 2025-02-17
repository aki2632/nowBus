//
//  GGBusInfoApp.swift
//  GGBusInfo
//
//  Created by sumin on 2/3/25.
//

import SwiftUI

@main
struct GGBusInfoApp: App {
    @StateObject var appearanceSettings = AppearanceSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appearanceSettings)
                .preferredColorScheme(appearanceSettings.isDarkMode ? .dark : .light)
        }
    }
}
