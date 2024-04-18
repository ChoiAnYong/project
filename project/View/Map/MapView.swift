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
    @StateObject var viewModel: MapViewModel
    
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
                    Coordinator.shared.setMarker(lat: user.latitude, 
                                                 lng:user.longitude,
                                                 name:user.name )
                }
            }
        }
    }
}

fileprivate struct LocationBtnView: View {
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
    MapView(viewModel: MapViewModel(container: .init(services: StubService())))
}
