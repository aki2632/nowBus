//
//  BusStationAroundResponse.swift
//  GGBusInfo
//
//  Created by sumin on 2/3/25.
//

import Foundation

// API 응답 최상위 모델
struct BusStationAroundResponse: Codable {
    let response: BusStationAroundResponseBody
}

struct BusStationAroundResponseBody: Codable {
    let msgBody: BusStationAroundMsgBody
}

struct BusStationAroundMsgBody: Codable {
    let busStationAroundList: [BusStationAround]
}

// 각 정류장 항목: stationId, stationName, mobileNo, regionName, x, y, distance 등을 포함합니다.
struct BusStationAround: Codable, Identifiable {
    var id: Int { stationId }  // stationId를 고유 ID로 사용
    let centerYn: String
    let mobileNo: Int
    let regionName: String
    let stationId: Int
    let stationName: String
    let x: Double
    let y: Double
    let distance: Int
    
    enum CodingKeys: String, CodingKey {
        case centerYn, mobileNo, regionName, stationId, stationName, x, y, distance
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
        distance = try container.decode(Int.self, forKey: .distance)
    }
}
