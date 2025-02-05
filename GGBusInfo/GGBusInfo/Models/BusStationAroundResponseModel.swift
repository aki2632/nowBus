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
    let mobileNo: String
    let regionName: String
    let stationId: Int
    let stationName: String
    let x: Double
    let y: Double
    let distance: Int
}
