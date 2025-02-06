//
//  TimeDisplayView.swift
//  GGBusInfo
//
//  Created by sumin on 2/4/25.
//

import SwiftUI

struct TimeDisplayView: View {
    let seconds: Int?
    
    // 전체 프레임 너비를 totalWidth로 통일
    private let totalWidth: CGFloat = 70
    
    var body: some View {
        HStack(spacing: 0) {
            if let sec = seconds, sec > 0 {
                let time = sec - 1
                let minutes = time / 60
                let secondsRemaining = time % 60
                
                // 분이 0이면 초만 표시, 그렇지 않으면 분과 초 모두 표시
                let formattedTime: String = minutes > 0
                    ? String(format: "%d분 %d초", minutes, secondsRemaining)
                    : String(format: "%d초", secondsRemaining)
                
                Text(formattedTime)
                    .monospacedDigit()
                    .frame(width: totalWidth, alignment: .leading)
            } else {
                Text("도착정보없음")
                    .frame(width: totalWidth, alignment: .leading)
                    .foregroundStyle(Color.gray)
                    .font(.system(size: 12))
            }
        }
        .font(.caption)
    }
}
