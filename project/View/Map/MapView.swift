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
        VStack {
            NaverMap()
                .edgesIgnoringSafeArea(.top)
        }
        .onAppear {
            Coordinator.shared.checkIfLocationServiceIsEnabled()
            Task {
                for user in viewModel.ussers {
                    Coordinator.shared.setMarker(lat: user.latitude, lng:user.longitude, name:user.name )
                }
            }
        }
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
