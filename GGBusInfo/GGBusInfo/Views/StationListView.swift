//
//  StationListView.swift
//  GgBus
//
//  Created by sumin on 2/3/25.
//

import SwiftUI
import Combine

enum StationSearchMode: String, CaseIterable, Identifiable {
    case keyword = "정류장 검색"
    case location = "근처 정류장 검색"
    
    var id: String { self.rawValue }
}

struct StationListView: View {
    @State private var searchText: String = ""
    @State private var keywordStations: [BusStation] = []  // 정류장 검색 결과
    @State private var aroundStations: [BusStationAround] = [] // 현재 위치 기반 검색 결과
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var searchMode: StationSearchMode = .keyword  // 기본은 키워드 검색 모드
    
    // 디바운스 작업을 저장하기 위한 cancellable 변수
    @State private var searchDebounceWorkItem: DispatchWorkItem?
    
    var body: some View {
        NavigationView {
            VStack {
                // 모드 선택 Picker: 검색 결과 / 현재위치 결과
                Picker("검색 모드", selection: $searchMode) {
                    ForEach(StationSearchMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top)
                
                if searchMode == .keyword {
                    // 키워드 검색용 검색바
                    TextField("정류소명 또는 번호 입력", text: $searchText)
                        .textFieldStyle(RoundedTextFieldStyle())
                        .padding(.horizontal)
                        // 텍스트 변경 시 디바운스를 적용하여 검색 호출
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
                } else {
                    // 현재 위치 기반 검색 모드의 경우
                    Button(action: {
                        fetchAroundStations()
                    }) {
                        Text("근처 정류장 검색")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                }
                
                if isLoading {
                    ProgressView("검색 중...")
                        .padding()
                }
                
                List {
                    if searchMode == .keyword {
                        ForEach(keywordStations) { station in
                            NavigationLink(destination: BusArrivalInfoView(
                                stationId: "\(station.stationId)",
                                stationName: station.stationName,
                                mobileNo: String(format: "%d", station.mobileNo)
                            )) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(station.stationName)")
                                        .font(.headline)
                                    Text(String(format: "%d", station.mobileNo))
                                        .font(.caption)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    } else {
                        ForEach(aroundStations) { station in
                            NavigationLink(destination: BusArrivalInfoView(
                                stationId: "\(station.stationId)",
                                stationName: station.stationName,
                                mobileNo: String(format: "%d", station.mobileNo)
                            )) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(station.stationName)")
                                        .font(.headline)
                                    HStack {
                                        Text(String(format: "%d", station.mobileNo))
                                            .font(.caption)
                                        Spacer()
                                        Text("거리: \(station.distance) m")
                                            .font(.caption)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .background(AppTheme.backgroundColor.edgesIgnoringSafeArea(.all))
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

struct StationListView_Previews: PreviewProvider {
    static var previews: some View {
        StationListView()
    }
}
