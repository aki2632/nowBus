//
//  FavoriteStationManager.swift
//  GGBusInfo
//
//  Created by sumin on 2/3/25.
//

import Foundation
import RealmSwift

class FavoriteStationManager: ObservableObject {
    private var realm: Realm
    @Published var favoriteStations: [FavoriteStation] = []
    
    init() {
        do {
            realm = try Realm()
            fetchFavoriteStations()
//            if let fileURL = Realm.Configuration.defaultConfiguration.fileURL {
//                print("Realm 파일 경로: \(fileURL)")
//            }
        } catch {
            fatalError("Realm 초기화 실패: \(error)")
        }
    }
    
    func fetchFavoriteStations() {
        let results = realm.objects(FavoriteStation.self)
        favoriteStations = Array(results)
    }
    
    // 정류장 즐겨찾기 추가 (없으면 새로 생성, 있으면 업데이트)
    func addFavoriteStation(stationId: String, stationName: String, mobileNo: String) {
        let favoriteStation: FavoriteStation
        if let existing = realm.object(ofType: FavoriteStation.self, forPrimaryKey: stationId) {
            favoriteStation = existing
        } else {
            favoriteStation = FavoriteStation()
            favoriteStation.stationId = stationId
        }
        favoriteStation.stationName = stationName
        favoriteStation.mobileNo = mobileNo // 정류장 번호 저장

        do {
            try realm.write {
                realm.add(favoriteStation, update: .modified)
            }
            fetchFavoriteStations()
        } catch {
            print("정류장 즐겨찾기 추가 실패: \(error)")
        }
    }
    
    func removeFavoriteStation(stationId: String) {
        if let station = realm.object(ofType: FavoriteStation.self, forPrimaryKey: stationId) {
            do {
                try realm.write {
                    realm.delete(station)
                }
                fetchFavoriteStations()
            } catch {
                print("정류장 즐겨찾기 삭제 실패: \(error)")
            }
        }
    }
    
    // 특정 정류장 내에 버스 노선 즐겨찾기 추가
    func addFavoriteBusRoute(stationId: String, routeId: Int, routeName: String) {
        guard let station = realm.object(ofType: FavoriteStation.self, forPrimaryKey: stationId) else {
            print("해당 정류장이 즐겨찾기에 없습니다.")
            return
        }
        if station.busRoutes.first(where: { $0.routeId == routeId }) != nil {
            // 이미 즐겨찾기에 있으면 아무 작업도 하지 않음
            return
        }
        let newRoute = FavoriteBusRoute()
        newRoute.routeId = routeId
        newRoute.routeName = routeName
        
        do {
            try realm.write {
                station.busRoutes.append(newRoute)
            }
            // fetchFavoriteStations() 호출 제거 → 목록 전체 갱신 방지
        } catch {
            print("버스 노선 즐겨찾기 추가 실패: \(error)")
        }
    }

    func removeFavoriteBusRoute(stationId: String, routeId: Int) {
        guard let station = realm.object(ofType: FavoriteStation.self, forPrimaryKey: stationId) else {
            print("해당 정류장이 즐겨찾기에 없습니다.")
            return
        }
        if let index = station.busRoutes.firstIndex(where: { $0.routeId == routeId }) {
            do {
                try realm.write {
                    station.busRoutes.remove(at: index)
                }
                // fetchFavoriteStations() 호출 제거 → 목록 전체 갱신 방지
            } catch {
                print("버스 노선 즐겨찾기 삭제 실패: \(error)")
            }
        }
    }

    // 즐겨찾기 여부 확인
    func isFavoriteStation(stationId: String) -> Bool {
        return realm.object(ofType: FavoriteStation.self, forPrimaryKey: stationId) != nil
    }
    
    func isFavoriteBusRoute(stationId: String, routeId: Int) -> Bool {
        guard let station = realm.object(ofType: FavoriteStation.self, forPrimaryKey: stationId) else {
            return false
        }
        return station.busRoutes.contains(where: { $0.routeId == routeId })
    }
}
