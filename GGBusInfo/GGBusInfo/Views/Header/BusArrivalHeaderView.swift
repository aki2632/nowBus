//
//  BusArrivalHeaderView.swift
//  GGBusInfo
//
//  Created by sumin on 2/10/25.
//

import SwiftUI

struct BusArrivalHeaderView: View {
    let mobileNo: String
    let isFavoriteStation: Bool
    let toggleFavorite: () -> Void
    @Binding var showNavigationBarFavorite: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text(mobileNo)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                // 스크롤에 따라 네비게이션 바에 별 버튼이 노출될 때는 헤더 내 버튼 숨김
                if !showNavigationBarFavorite {
                    Button(action: toggleFavorite) {
                        Image(systemName: isFavoriteStation ? "star.fill" : "star")
                            .foregroundColor(isFavoriteStation ? AppTheme.accentColor : .gray)
                            .font(.system(size: 20))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.gray))
        // 스크롤 오프셋에 따라 showNavigationBarFavorite 값을 업데이트
        .background(GeometryReader { proxy -> Color in
            let offset = proxy.frame(in: .global).minY
            DispatchQueue.main.async {
                withAnimation {
                    showNavigationBarFavorite = offset < -100
                }
            }
            return Color.clear
        })
    }
}
