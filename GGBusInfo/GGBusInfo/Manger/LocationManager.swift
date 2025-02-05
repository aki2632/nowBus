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
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
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

struct LocationContentView: View {
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            if let location = locationManager.location {
                Text("위도: \(location.coordinate.latitude)")
                Text("경도: \(location.coordinate.longitude)")
            } else {
                Text("위치 정보를 가져오는 중...")
            }
        }
        .padding()
    }
}
