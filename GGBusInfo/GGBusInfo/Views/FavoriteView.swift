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
                                    .background(AppTheme.customBlack)
                                    .cornerRadius(5)
                                    .padding(.horizontal, 0)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .background(AppTheme.backgroundColor.edgesIgnoringSafeArea(.all))
                
                if favoriteStationManager.favoriteStations.isEmpty {
                    VStack {
                        Spacer()
                        Text("즐겨찾기를 추가해주세요")
                            .foregroundColor(.gray)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                        Spacer()
                    }
                    .background(AppTheme.backgroundColor.edgesIgnoringSafeArea(.all))
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        RefreshButtonView(action: {
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
