//
//  DualTimeDisplayView.swift
//  GGBusInfo
//
//  Created by sumin on 2/4/25.
//

import SwiftUI

struct DualTimeDisplayView: View {
    let seconds1: Int?
    let seconds2: Int?
    
    var body: some View {
        VStack(spacing: 4) {
            // 첫 번째 도착시간 표시
            TimeDisplayView(seconds: seconds1)
            
            // 두 번째 도착시간 표시
            TimeDisplayView(seconds: seconds2)
        }
    }
}
