//
//  OptionView.swift
//  GGBusInfo
//
//  Created by sumin on 2/11/25.
//

import SwiftUI

struct OptionView: View {
    @EnvironmentObject var appearanceSettings: AppearanceSettings

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var minimumOSVersion: String {
        Bundle.main.infoDictionary?["MinimumOSVersion"] as? String ?? "12.0"
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Appearance 섹션: 다크모드 토글 스위치
                Section {
                    Toggle("다크모드", isOn: $appearanceSettings.isDarkMode)
                        .accessibilityIdentifier("darkModeToggle")
                }
                
                // App Information 섹션
                Section {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text(appVersion)
                    }
                    HStack {
                        Text("Minimum Target")
                        Spacer()
                        Text("iOS \(minimumOSVersion)")
                    }
                }
                
                // Legal 섹션
                Section {
                    Link("개인정보 보호 방침", destination: URL(string: "https://aki2632apple.blogspot.com/2025/02/1.html")!)
                }
                
                // 개발자 섹션
                Section {
                    HStack {
                        Text("개발자")
                        Spacer()
                        Text("L S M")
                    }
                }
            }
        }
        .preferredColorScheme(appearanceSettings.isDarkMode ? .dark : .light)
    }
}
