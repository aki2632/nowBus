//
//  AppearanceSettings.swift
//  GGBusInfo
//
//  Created by sumin on 2/13/25.
//

import Foundation
import SwiftUI

class AppearanceSettings: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
}
