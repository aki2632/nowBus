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
                                    .background(Color(.white))
                                    .cornerRadius(5)
                                    .padding(.horizontal, 0)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color(.systemGray5))
                
                // 즐겨찾기가 비어있을 때 안내 문구 표시
                if favoriteStationManager.favoriteStations.isEmpty {
                    VStack {
                        Spacer()
                        Text("즐겨찾기를 추가해주세요")
                            .foregroundColor(.gray)
                            .font(.title3)
                        Spacer()
                    }
                }
                
                // 우측 하단 새로고침 버튼 (분리한 RefreshButtonView 사용)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        RefreshButtonView(action: {
                            // 새로고침 시 알림 전송
                            NotificationCenter.default.post(name: Notification.Name("RefreshBusArrival"), object: nil)
                        })
                        .padding()
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
