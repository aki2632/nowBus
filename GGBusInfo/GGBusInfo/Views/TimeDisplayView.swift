//
//  TimeDisplayView.swift
//  GGBusInfo
//
//  Created by sumin on 2/4/25.
//

import SwiftUI

struct TimeDisplayView: View {
    let seconds: Int?
    
    // 필요에 따라 고정 너비 조정 (여기서는 예시로 적당한 값 사용)
    private let minuteWidth: CGFloat = 35
    private let secondWidth: CGFloat = 35
    
    var body: some View {
        HStack(spacing: 0) {
            if let sec = seconds, sec > 0 {
                let time = sec - 1
                let minutes = time / 60
                let secondsRemaining = time % 60
                
                Text(String(format: "%02d분", minutes))
                    .monospacedDigit()
                    .frame(width: minuteWidth, alignment: .trailing)
                Text(String(format: " %02d초", secondsRemaining))
                    .monospacedDigit()
                    .frame(width: secondWidth, alignment: .trailing)
            } else {
                Text("정보 없음")
                    .frame(width: minuteWidth + secondWidth, alignment: .trailing)
            }
        }
        .font(.caption)
    }
}
