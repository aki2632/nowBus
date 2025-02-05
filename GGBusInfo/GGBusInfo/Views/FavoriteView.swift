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
            List {
                ForEach(favoriteStationManager.favoriteStations) { station in
                    NavigationLink(destination: BusArrivalInfoView(
                        stationId: station.stationId,
                        stationName: station.stationName,
                        mobileNo: station.mobileNo)
                    ) {
                        FavoriteStationRowView(station: station)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .onDelete { offsets in
                    for index in offsets {
                        let station = favoriteStationManager.favoriteStations[index]
                        favoriteStationManager.removeFavoriteStation(stationId: station.stationId)
                    }
                }
            }
        }
    }
}
