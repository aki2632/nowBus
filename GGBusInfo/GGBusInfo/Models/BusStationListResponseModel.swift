//
//  BusStationListResponse.swift
//  GGBusInfo
//
//  Created by sumin on 2/4/25.
//

import Foundation

struct BusStationListResponse: Codable {
    let response: BusStationListResponseBody
}

struct BusStationListResponseBody: Codable {
    let msgBody: BusStationListMsgBody
}

struct BusStationListMsgBody: Codable {
    let busStationList: [BusStation]
}

struct BusStation: Codable, Identifiable {
    var id: Int { stationId }
    let centerYn: String
    let mobileNo: Int
    let regionName: String
    let stationId: Int
    let stationName: String
    let x: Double
    let y: Double

    enum CodingKeys: String, CodingKey {
        case centerYn, mobileNo, regionName, stationId, stationName, x, y
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        centerYn = try container.decode(String.self, forKey: .centerYn)
        let mobileNoString = try container.decode(String.self, forKey: .mobileNo)
        guard let mobileNoValue = Int(mobileNoString.trimmingCharacters(in: .whitespaces)) else {
            throw DecodingError.dataCorruptedError(forKey: .mobileNo, in: container, debugDescription: "mobileNo is not a valid integer.")
        }
        mobileNo = mobileNoValue
        regionName = try container.decode(String.self, forKey: .regionName)
        stationId = try container.decode(Int.self, forKey: .stationId)
        stationName = try container.decode(String.self, forKey: .stationName)
        x = try container.decode(Double.self, forKey: .x)
        y = try container.decode(Double.self, forKey: .y)
    }
}
