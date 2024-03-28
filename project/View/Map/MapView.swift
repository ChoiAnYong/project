//
//  MapView.swift
//  project
//
//  Created by 최안용 on 3/27/24.
//

import SwiftUI
import NMapsMap

struct MapView: View {
    var body: some View {
        ZStack {
            UIMapView()
                .edgesIgnoringSafeArea(.top)
            
            
        }
    }
}

fileprivate struct asd: View {
    var body: some View {
        Text("dsk")
    }
}

struct UIMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()
        view.showZoomControls = false
        view.mapView.positionMode = .direction
        view.mapView.zoomLevel = 17
        view.mapView.logoInteractionEnabled = false
        
        view.showLocationButton = true
        view.showScaleBar = true
        view.showZoomControls = true
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {}
}

#Preview {
    MapView()
}
