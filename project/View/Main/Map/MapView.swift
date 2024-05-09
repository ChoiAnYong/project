//
//  MapView.swift
//  project
//
//  Created by 최안용 on 3/27/24.
//

import SwiftUI
import NMapsMap
import UIKit

struct MapView: View {
    @EnvironmentObject private var mainViewModel: MainViewModel
    @EnvironmentObject private var container: DIContainer
    
    @StateObject var mapViewModel: MapViewModel
    @StateObject var coordinator: Coordinator
    
    var body: some View {
        ZStack {
            NaverMap(coordinator: coordinator, mapViewModel: mapViewModel)
                .edgesIgnoringSafeArea(.top)

            LocationBtnView(coordinator: coordinator)
                .offset(x:0, y: UIScreen.main.bounds.height/3.5)
        }
        .onAppear {
            coordinator.checkIfLocationServiceIsEnabled()
            mapViewModel.send(action: .loadUserMarker(mainViewModel.users))
            
        }
    }
}

struct LocationBtnView: View {
    private var coordinator: Coordinator
    
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                coordinator.moveMapToUserLocation()
            } label: {
                CustomIcon(iconName: "ic_locationBtn")
            }
        }
        .padding(.horizontal, 15)
    }
}

struct NaverMap: UIViewRepresentable {
    @EnvironmentObject private var mainViewModel: MainViewModel
    @ObservedObject private var mapViewModel: MapViewModel
    
    private var coordinator: Coordinator
    
    init(coordinator: Coordinator, mapViewModel: MapViewModel) {
        self.coordinator = coordinator
        self.mapViewModel = mapViewModel
        coordinator.setMarker(markers: mapViewModel.userMarkerList)
    }
    
    func makeCoordinator() -> Coordinator {
        coordinator
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        coordinator.getNaverMapView()
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        
    }
}

#Preview {
    MapView(mapViewModel: MapViewModel(), coordinator: Coordinator(container: DIContainer(services: StubService())))
        .environmentObject(MainViewModel(container: .init(services: StubService())))
}
