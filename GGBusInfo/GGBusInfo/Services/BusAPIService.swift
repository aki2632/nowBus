//
//  BusAPIService.swift
//  GgBus
//
//  Created by sumin on 2/3/25.
//

import Foundation

class BusAPIService {
    static let shared = BusAPIService()
    
    // 기존 버스 도착 정보 관련 URL, 서비스키 (URL 인코딩된 값 사용)
    private let arrivalBaseUrl = "https://apis.data.go.kr/6410000/busarrivalservice/v2/getBusArrivalListv2"
    private let arrivalServiceKey = "%2Bujoe1yFps8mEzNRHgtZiF%2FeWV7RtTqpUAaG1V8VC8KUQxH7llDIRG1smyQe8I1lKpFOjJMSpuP5diO%2FkwIcVA%3D%3D"
    
    // 버스 정류장 주변 목록 관련 URL, 서비스키 (URL 인코딩된 값 사용)
    private let stationAroundBaseUrl = "https://apis.data.go.kr/6410000/busstationservice/v2/getBusStationAroundListv2"
    private let stationAroundServiceKey: String = "KSxcmH8OHMnLZPXqdzRqxyQ1xaVJmUyJXD4VuqzgOHcymiiCYj04q7aGabf5vnzhO0RzTujLbORqU5S2hAmBsA=="
    
    // **추가**: 버스 정류장 검색 관련 URL, 서비스키 (URL 인코딩된 값 사용)
    private let stationListBaseUrl = "http://apis.data.go.kr/6410000/busstationservice/v2/getBusStationListv2"
    private let stationListServiceKey: String = "KSxcmH8OHMnLZPXqdzRqxyQ1xaVJmUyJXD4VuqzgOHcymiiCYj04q7aGabf5vnzhO0RzTujLbORqU5S2hAmBsA=="
    
    // 기존 함수: 버스 도착 정보 API 호출 함수
    func fetchBusArrivalInfo(for stationId: String, completion: @escaping (Result<[BusArrival], Error>) -> Void) {
        let urlString = "\(arrivalBaseUrl)?serviceKey=\(arrivalServiceKey)&stationId=\(stationId)"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Accept": "application/json"]
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "No Data", code: 0))) }
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(BusArrivalResponse.self, from: data)
                let arrivals = response.response.msgBody.busArrivalList
                DispatchQueue.main.async {
                    completion(.success(arrivals))
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    // 기존 함수: 버스 정류장 주변 목록 API 호출 함수
    func fetchBusStationAroundList(x: Double, y: Double, completion: @escaping (Result<[BusStationAround], Error>) -> Void) {
        let urlString = "\(stationAroundBaseUrl)?serviceKey=\(stationAroundServiceKey)&x=\(x)&y=\(y)&format=json"
        print("Constructed URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No Data", code: 0)))
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(BusStationAroundResponse.self, from: data)
                let stations = response.response.msgBody.busStationAroundList
                DispatchQueue.main.async {
                    completion(.success(stations))
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    // **추가**: 정류장 검색 API 호출 함수 (keyword 기반)
    func fetchBusStationList(keyword: String, completion: @escaping (Result<[BusStation], Error>) -> Void) {
        let urlString = "\(stationListBaseUrl)?format=json&serviceKey=\(stationListServiceKey)&keyword=\(keyword)"
        print("Constructed Station List URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No Data", code: 0)))
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(BusStationListResponse.self, from: data)
                // 변경: 바로 busStationList 배열 사용
                let stations = response.response.msgBody.busStationList
                DispatchQueue.main.async {
                    completion(.success(stations))
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}
