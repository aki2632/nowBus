//
//  LocationManager.swift
//  GGBusInfo
//
//  Created by sumin on 2/3/25.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation? = nil
    @Published var error: Error? = nil
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 초기 권한 요청은 여기서 하지 않고, 필요 시 호출하도록 변경합니다.
        // locationManager.requestWhenInUseAuthorization()
    }
    
    // 외부에서 권한 요청을 호출할 수 있도록 공개 메서드를 추가합니다.
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // iOS 14 이상에서 권장되는 권한 변경 콜백
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // 권한이 허용된 경우에만 위치 업데이트 시작
            manager.startUpdatingLocation()
        case .denied, .restricted:
            // 권한이 거부되었거나 제한된 경우 에러를 설정합니다.
            self.error = CLError(.denied)
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        if let loc = location {
            print("업데이트된 위치: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
}
