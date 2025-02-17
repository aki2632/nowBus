//
//  RefreshButtonView.swift
//  GGBusInfo
//
//  Created by sumin on 2/10/25.
//

import SwiftUI

struct RefreshButtonView: View {
    let action: () -> Void
    @State private var rotation: Double = 0
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            action()
            // 중복 애니메이션 방지
            guard !isAnimating else { return }
            isAnimating = true
            rotation += 720
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isAnimating = false
            }
        }) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 20))
                .padding()
                .background(AppTheme.customWhite)
                .foregroundColor(AppTheme.customBlack)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 2, y: 2)
                .rotationEffect(.degrees(rotation))
                .animation(.linear(duration: 1), value: rotation)
        }
    }
}
