//
//  StationKeywordRowView.swift
//  GGBusInfo
//
//  Created by sumin on 2/10/25.
//

import SwiftUI

struct StationKeywordRowView: View {
    let station: BusStation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(station.stationName)
                .font(.headline)
            Text(String(format: "%d", station.mobileNo))
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}
