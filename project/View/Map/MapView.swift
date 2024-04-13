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
    
    var body: some View {
        VStack {
            NaverMap()
                .edgesIgnoringSafeArea(.top)
        }
        .onAppear {
            Coordinator.shared.checkIfLocationServiceIsEnabled()
            Task {
                Coordinator.shared.setMarker(lat: User.stub2.latitude, lng:User.stub2.longitude, name:User.stub2.name )
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
}
