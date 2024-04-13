//
//  Coordinator.swift
//  project
//
//  Created by 최안용 on 4/11/24.
//

import Foundation
import NMapsMap
import CoreLocation

final class Coordinator: NSObject, ObservableObject {
    @Published var userLocation: (Double, Double) = (0.0, 0.0)
    
    private var locationManager: CLLocationManager?
    
    static let shared = Coordinator()
    
    let view = NMFNaverMapView(frame: .zero)
    
    override init() {
        super.init()
        
        view.mapView.positionMode = .direction
        view.mapView.isNightModeEnabled = false
        
        view.mapView.zoomLevel = 15
        view.mapView.minZoomLevel = 5
        view.mapView.maxZoomLevel = 17
        
        // 사용자 인터페이스
        view.showCompass = false
        view.showScaleBar = false
        view.showZoomControls = false
        view.showLocationButton = true
        
        // 네이버 로고 위치 조정
        view.mapView.logoAlign = .leftBottom
        view.mapView.logoMargin = .init(top: 0, left: 0, bottom: 110, right: 0)
        
        // 틸트 제스처 비활성화
        view.mapView.isTiltGestureEnabled = false
        
        view.mapView.addCameraDelegate(delegate: self)
        view.mapView.touchDelegate = self
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("위치 정보 접근이 제한되었습니다.")
        case .denied:
            print("위치 정보 접근을 거절했습니다. 설정에서 변경하세요.")
        case .authorizedAlways, .authorizedWhenInUse:
            print("Success")
            
            fetchUserLocation()
            
        @unknown default:
            break
        }
    }
    
    func checkIfLocationServiceIsEnabled() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self.locationManager = CLLocationManager()
                    self.locationManager!.delegate = self
                    
                    self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                    self.locationManager?.distanceFilter = 10
                    self.checkLocationAuthorization()
                }
            } else {
                print("Show an alert letting them know this is off and to go turn i on")
            }
        }
    }
    
    func getNaverMapView() -> NMFNaverMapView {
        view
    }
}

// 위치 관련
extension Coordinator: CLLocationManagerDelegate {
    func fetchUserLocation() {
        if let locationManager = locationManager {
            userLocation.0 = locationManager.location?.coordinate.latitude ?? 0.0
            userLocation.1 = locationManager.location?.coordinate.longitude ?? 0.0
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: userLocation.0, lng: userLocation.1), zoomTo: 15)
            cameraUpdate.animation = .fly
            cameraUpdate.animationDuration = 1
            
            let locationOverlay = view.mapView.locationOverlay
            locationOverlay.location = NMGLatLng(lat: userLocation.0, lng: userLocation.1)
            locationOverlay.hidden = false

            locationOverlay.icon = .init(image: UIImage(resource: .icon))
            locationOverlay.iconWidth = 60
            locationOverlay.iconHeight = 60
            
            locationOverlay.anchor = CGPoint(x: 0.5, y: 1)
            
            view.mapView.moveCamera(cameraUpdate)
        }
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        fetchUserLocation()
//    }
}

// 카메라 관련 이벤트
extension Coordinator: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        
    }
}

// 터치 관련 이벤트
extension Coordinator: NMFMapViewTouchDelegate {
    
}

// 마커
extension Coordinator {
    func setMarker(lat : Double, lng: Double, name: String) {
          let marker = NMFMarker()
          marker.iconImage = NMF_MARKER_IMAGE_PINK
          marker.position = NMGLatLng(lat: lat, lng: lng)
          marker.mapView = view.mapView
          
          let infoWindow = NMFInfoWindow()
          let dataSource = NMFInfoWindowDefaultTextSource.data()
          dataSource.title = name
          infoWindow.dataSource = dataSource
          infoWindow.open(with: marker)
      }
//    func makeMarker() {
//        let users: [User] = [User.stub2, User.stub3, User.stub4, User.stub5]
//        let infowindow = NMFInfoWindow()
//        let dataSource = NMFInfoWindowDefaultTextSource.data()
//        DispatchQueue.global(qos: .default).async {
//            var markers = [NMFMarker]()
//            for user in users {
//                let marker = NMFMarker(position: NMGLatLng(lat: user.latitude, lng: user.longitude))
//                marker.iconImage = NMFOverlayImage(name: "location_overlay_icon")
//                marker.captionText = user.name
//                
//                markers.append(marker)
//            }
//            
//            DispatchQueue.main.async { [weak self] in
//                for marker in markers {
//                    marker.mapView = self?.view.mapView
//                    dataSource.title = "dksljfl"
//                    infowindow.dataSource = dataSource
//                    infowindow.open(with: marker)
//                }
//            }
//        }
//    }
}



