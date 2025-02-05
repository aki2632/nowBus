//
//  BusModels.swift
//  GgBus
//
//  Created by sumin on 2/3/25.
//

import Foundation

// BusArrivalResponse 모델 정의
struct BusArrivalResponse: Codable {
    let response: BusArrivalResponseBody
}

struct BusArrivalResponseBody: Codable {
    let msgBody: BusArrivalMsgBody
}

struct BusArrivalMsgBody: Codable {
    let busArrivalList: [BusArrival]
}

// BusArrival 모델 정의
struct BusArrival: Codable, Identifiable {
    var id: Int { routeId }  // routeId를 id로 설정
    var routeId: Int
    var routeName: String
    var predictTimeSec1: Int?
    var predictTimeSec2: Int?
    var routeDestName: String
    
    // 커스텀 초기화로 routeName을 String과 Int 모두 처리
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        routeId = try container.decode(Int.self, forKey: .routeId)
        
        // routeName을 Int 또는 String으로 처리
        if let routeNameInt = try? container.decode(Int.self, forKey: .routeName) {
            routeName = String(routeNameInt)  // routeName이 숫자일 경우 String으로 변환
        } else {
            routeName = try container.decode(String.self, forKey: .routeName)  // routeName이 문자열일 경우 그대로 사용
        }
        
        // predictTimeSec1과 predictTimeSec2 디코딩
        predictTimeSec1 = try? container.decode(Int.self, forKey: .predictTimeSec1)
        predictTimeSec2 = try? container.decode(Int.self, forKey: .predictTimeSec2)
        routeDestName = try container.decode(String.self, forKey: .routeDestName)
    }
}
