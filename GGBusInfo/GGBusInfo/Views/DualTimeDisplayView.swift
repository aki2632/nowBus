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
        HStack(spacing: 4) {
            // 첫 번째 도착시간 표시
            TimeDisplayView(seconds: seconds1)
            
            // 구분 기호
            Text("|")
                .font(.caption)
                .foregroundColor(.gray)
                .fixedSize(horizontal: true, vertical: true)
            
            // 두 번째 도착시간 표시
            TimeDisplayView(seconds: seconds2)
        }
    }
}
