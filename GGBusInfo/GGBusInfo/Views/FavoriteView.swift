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
                    ZStack(alignment: .leading) {
                        // Invisible navigation link to trigger navigation without showing the arrow
                        NavigationLink(destination: BusArrivalInfoView(
                            stationId: station.stationId,
                            stationName: station.stationName,
                            mobileNo: station.mobileNo)
                        ) {
                            EmptyView()
                        }
                        .opacity(0)
                        
                        // Your custom station row view
                        FavoriteStationRowView(station: station)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
        }
    }
}
