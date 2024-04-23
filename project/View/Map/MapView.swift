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
    @StateObject var coordinator: Coordinator = Coordinator.shared
    @EnvironmentObject private var viewModel: MainViewModel
    
    var body: some View {
        ZStack {
            NaverMap()
                .edgesIgnoringSafeArea(.top)
            
            LocationBtnView()
                .offset(x:0, y: UIScreen.main.bounds.height/3.5)
        }
        .onAppear {
            Coordinator.shared.checkIfLocationServiceIsEnabled()
            Task {
                for user in viewModel.users {
                    guard let lat = user.latitude,
                          let lng = user.longitude else { return }
                    
                    Coordinator.shared.setMarker(lat: lat,
                                                 lng: lng,
                                                 name:user.name )
                }
            }
        }
    }
}

struct LocationBtnView: View {
    var body: some View {
        HStack {
            Spacer()
            Button {
                Coordinator.shared.moveMapToUserLocation()
            } label: {
                CustomIcon(iconName: "locationIcon")
            }
        }
        .padding(.horizontal, 15)
    }
}

struct NaverMap: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator.shared
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        context.coordinator.getNaverMapView()
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        
    }
}

#Preview {
    MapView()
        .environmentObject(MainViewModel(container: .init(services: StubService())))
}
