//
//  TimeDisplayView.swift
//  GGBusInfo
//
//  Created by sumin on 2/4/25.
//

import SwiftUI

struct TimeDisplayView: View {
    let seconds: Int?
    
    // 각 열의 고정 너비를 정의 (필요에 따라 조절 가능)
    private let minuteWidth: CGFloat = 30
    private let labelWidth: CGFloat = 20
    private let secondWidth: CGFloat = 30
    
    var body: some View {
        HStack(spacing: 0) {
            if let sec = seconds, sec > 0 {
                let time = sec - 1
                let minutes = time / 60
                let secondsRemaining = time % 60
                
                // 고정된 열로 구성
                Text(String(format: "%2d", minutes))
                    .monospacedDigit()
                    .frame(width: minuteWidth, alignment: .trailing)
                Text("분")
                    .frame(width: labelWidth, alignment: .leading)
                Text(String(format: "%2d", secondsRemaining))
                    .monospacedDigit()
                    .frame(width: secondWidth, alignment: .trailing)
                Text("초")
                    .frame(width: labelWidth, alignment: .leading)
            } else {
                // 시간이 없을 경우에도 같은 총 너비(분, 레이블, 초 등)를 사용하여 중앙 정렬
                Text("정보없음")
                    .frame(width: minuteWidth + labelWidth + secondWidth + labelWidth, alignment: .trailing)
            }
        }
        .font(.caption)
    }
}
