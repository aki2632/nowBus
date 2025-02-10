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
    @State private var keywordStations: [BusStation] = []  // 키워드 검색 결과
    @State private var aroundStations: [BusStationAround] = [] // 현재 위치 기반 검색 결과
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var searchMode: StationSearchMode = .keyword  // 기본은 키워드 검색 모드
    
    // 디바운스 작업을 저장하기 위한 변수
    @State private var searchDebounceWorkItem: DispatchWorkItem?
    
    var body: some View {
        NavigationView {
            VStack {
                // 모드 선택 Picker: 키워드 검색 / 현재위치 기반 검색
                Picker("검색 모드", selection: $searchMode) {
                    ForEach(StationSearchMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top)
                
                if searchMode == .keyword {
                    // 커스텀 검색바: 좌측에 돋보기 아이콘, 중앙에 TextField, 우측에 클리어(x) 버튼
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("정류소명 또는 번호. 예) 백석역 또는 20311", text: $searchText)
                            .disableAutocorrection(true)
                            .onChange(of: searchText) { newValue in
                                // 디바운스 적용: 입력 후 0.5초 후에 검색
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
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .font(.system(size: 12))
                } else {
                    // "근처 정류장 검색" 모드에서는 버튼 없이 자동으로 검색
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
                            // 결과가 없을 때 전체 영역을 채우도록 frame modifier 적용
                            VStack {
                                Text("검색 결과가 없습니다.")
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
                                }
                            }
                            .listStyle(PlainListStyle())
                        }
                    } else {
                        if aroundStations.isEmpty {
                            // 결과가 없을 때 전체 영역을 채우도록 frame modifier 적용
                            VStack {
                                Text("검색 결과가 없습니다.")
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
                                }
                            }
                            .listStyle(PlainListStyle())
                        }
                    }
                }
            }
            .background(AppTheme.backgroundColor.edgesIgnoringSafeArea(.all))
            // 검색 모드가 변경될 때(.location) 자동으로 현재 위치 기반 정류장 검색 실행
            .onChange(of: searchMode) { newMode in
                if newMode == .location {
                    fetchAroundStations()
                }
            }
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

struct StationListView_Previews: PreviewProvider {
    static var previews: some View {
        StationListView()
    }
}
