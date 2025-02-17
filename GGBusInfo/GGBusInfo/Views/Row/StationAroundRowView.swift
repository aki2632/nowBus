//
//  StationAroundRowView.swift
//  GGBusInfo
//
//  Created by sumin on 2/10/25.
//

import SwiftUI

struct StationAroundRowView: View {
    let station: BusStationAround
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(station.stationName)
                .font(.headline)
            HStack {
                Text(String(format: "%d", station.mobileNo))
                    .font(.caption)
                Spacer()
                Text("\(station.distance) m")
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}
