//
//  StationListView.swift
//  GgBus
//
//  Created by sumin on 2/3/25.
//

import SwiftUI
import Combine
import CoreLocation

enum StationSearchMode: String, CaseIterable, Identifiable {
    case keyword = "정류장 검색"
    case location = "근처 정류장 검색"
    
    var id: String { self.rawValue }
}

struct StationListView: View {
    @State private var searchText: String = ""
    @State private var keywordStations: [BusStation] = []  // 키워드 검색 결과
    @State private var aroundStations: [BusStationAround] = [] // 현재 위치 기반 검색 결과
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var searchMode: StationSearchMode = .keyword  // 기본은 키워드 검색 모드
    @State private var showLocationAlert = false
    @StateObject var locationManager = LocationManager()
    
    // 디바운스 작업을 저장하기 위한 변수
    @State private var searchDebounceWorkItem: DispatchWorkItem?
    
    var body: some View {
        NavigationView {
            VStack {
                // 모드 선택 Picker
                Picker("검색 모드", selection: $searchMode) {
                    ForEach(StationSearchMode.allCases) { mode in
                        Text(mode.rawValue)
                            .font(.system(size: 18, weight: .medium))
                            .tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top)
                .frame(height: 80)
                
                if searchMode == .keyword {
                    // 검색바: 돋보기, 텍스트필드, 클리어 버튼
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                        
                        TextField("정류소명 또는 번호. 예) 백석역 또는 20311", text: $searchText)
                            .disableAutocorrection(true)
                            .font(.system(size: 15))
                            .onChange(of: searchText) { newValue in
                                searchDebounceWorkItem?.cancel()
                                let workItem = DispatchWorkItem {
                                    if !newValue.isEmpty {
                                        searchStations()
                                    } else {
                                        keywordStations = []
                                    }
                                }
                                searchDebounceWorkItem = workItem
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 18))
                            }
                        }
                    }
                    .padding(12)
                    .frame(height: 50)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .padding(.horizontal)
                } else {
                    EmptyView()
                }
                
                if isLoading {
                    ProgressView("검색 중...")
                        .padding()
                }
                
                // 검색 결과 영역
                Group {
                    if searchMode == .keyword {
                        if keywordStations.isEmpty {
                            VStack {
                                Text("검색 결과가 없습니다")
                                    .foregroundColor(.gray)
                                    .padding()
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        } else {
                            List {
                                ForEach(keywordStations) { station in
                                    NavigationLink(destination: BusArrivalInfoView(
                                        stationId: "\(station.stationId)",
                                        stationName: station.stationName,
                                        mobileNo: String(format: "%d", station.mobileNo)
                                    )) {
                                        StationKeywordRowView(station: station)
                                    }
                                    .listRowBackground(AppTheme.customBlack)
                                }
                            }
                            .listStyle(PlainListStyle())
                        }
                    } else {
                        if aroundStations.isEmpty {
                            VStack {
                                Text("검색 결과가 없습니다")
                                    .foregroundColor(.gray)
                                    .padding()
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        } else {
                            List {
                                ForEach(aroundStations) { station in
                                    NavigationLink(destination: BusArrivalInfoView(
                                        stationId: "\(station.stationId)",
                                        stationName: station.stationName,
                                        mobileNo: String(format: "%d", station.mobileNo)
                                    )) {
                                        StationAroundRowView(station: station)
                                    }
                                    .listRowBackground(AppTheme.customBlack)
                                }
                            }
                            .listStyle(PlainListStyle())
                        }
                    }
                }
            }
            .background(AppTheme.backgroundColor.edgesIgnoringSafeArea(.all))
            .onChange(of: searchMode) { newMode in
                let status = CLLocationManager.authorizationStatus()
                
                if status == .denied || status == .restricted {
                    // 모드 변경 시 검색 결과 및 텍스트 초기화
                    self.keywordStations = []
                    self.aroundStations = []
                    self.searchText = ""
                }
                
                if newMode == .location {
                    checkLocationStatus()
                    fetchAroundStations()
                }
            }
        }
        .alert(isPresented: $showLocationAlert) {
            Alert(
              title: Text("위치 Off"),
              message: Text("현재 위치를 파악할 수 없습니다. \n\n설정에서 위치 서비스를 활성화해주세요.\n앱을 사용하는 동안 허용에 체크해주세요."),
              primaryButton: .default(Text("설정 이동"), action: {
                openAppSettings()
              }),
              secondaryButton: .cancel()
            )
        }
    }
    
    func checkLocationStatus() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            locationManager.requestAuthorization()  // 수정된 부분
            showLocationAlert = false
        case .authorizedAlways, .authorizedWhenInUse:
            showLocationAlert = false
        case .denied, .restricted:
            showLocationAlert = true
        @unknown default:
            showLocationAlert = false
        }
    }
   
    // 설정 이동
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // 키워드 검색 API 호출 함수
    func searchStations() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        BusAPIService.shared.fetchBusStationList(keyword: searchText) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedStations):
                    self.keywordStations = fetchedStations
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // 현재 위치 기반 검색 API 호출 함수
    func fetchAroundStations() {
        isLoading = true
        errorMessage = nil
        
        let locationManager = LocationManager()
        // 간단한 딜레이 후 위치 정보를 확인 (실제 앱에서는 LocationManager의 delegate나 async/await 패턴을 활용할 수 있습니다.)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard let currentLocation = locationManager.location else {
                self.errorMessage = "현재 위치를 가져올 수 없습니다."
                self.isLoading = false
                return
            }
            let currentX = currentLocation.coordinate.longitude
            let currentY = currentLocation.coordinate.latitude
            
            BusAPIService.shared.fetchBusStationAroundList(x: currentX, y: currentY) { result in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success(let fetchedStations):
                        self.aroundStations = fetchedStations
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}
