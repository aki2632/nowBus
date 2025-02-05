//
//  FavoriteType.swift
//  GGBusInfo
//
//  Created by sumin on 2/3/25.
//

import RealmSwift

// 버스 노선 즐겨찾기는 정류장에 항상 포함되므로 EmbeddedObject로 선언합니다.
class FavoriteBusRoute: EmbeddedObject {
    @objc dynamic var routeId: Int = 0
    @objc dynamic var routeName: String = ""
}

class FavoriteStation: Object, Identifiable {
    @objc dynamic var stationId: String = ""
    @objc dynamic var stationName: String = ""
    @objc dynamic var mobileNo: String = ""
    let busRoutes = List<FavoriteBusRoute>()

    override static func primaryKey() -> String? {
        return "stationId"
    }
}
