//
//  FavoriteView.swift
//  GgBus
//
//  Created by sumin on 2/3/25.
//

import SwiftUI
import RealmSwift

struct FavoriteView: View {
    @EnvironmentObject var favoriteStationManager: FavoriteStationManager
    @State private var rotation: Double = 0
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack {
                        ForEach(favoriteStationManager.favoriteStations) { station in
                            NavigationLink(destination: BusArrivalInfoView(
                                stationId: station.stationId,
                                stationName: station.stationName,
                                mobileNo: station.mobileNo)
                            ) {
                                FavoriteStationRowView(station: station)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(5)
                                    .padding(.horizontal, 0)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color(.systemGray5))
                
                // 우측 하단에 새로고침 버튼 배치
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // 버튼을 누르면 "RefreshBusArrival" 알림을 보냄
                            NotificationCenter.default.post(name: Notification.Name("RefreshBusArrival"), object: nil)
                            
                            // 애니메이션 중복 실행 방지를 위해 버튼 비활성화 가능
                            guard !isAnimating else { return }
                            isAnimating = true
                            rotation += 720
                            
                            // 1초 후(애니메이션 완료 시점) 상태를 초기화하여 원래 상태로 복귀
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                isAnimating = false
                            }
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .frame(width: 20, height: 20)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .rotationEffect(.degrees(rotation))
                                .animation(.linear(duration: 1), value: rotation)
                        }
                        .padding()
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
