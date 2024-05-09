//
//  Coordinator.swift
//  project
//
//  Created by 최안용 on 4/11/24.
//


import CoreLocation
import Foundation
import Combine
import NMapsMap

final class Coordinator: NSObject, ObservableObject {
    @Published var userLocation: (Double, Double) = (0.0, 0.0)
    var humanMarkerList: [NMFMarker] = []
    private var subscriptions = Set<AnyCancellable>()
    private var locationManager: CLLocationManager?
    private var container: DIContainer
    
    private var humanMarkerView: UserMarkerView
    
    private let locationOverlayIcon = NMFOverlayImage(name: "ic_location")
    private let locationOverlayNoArrowIcon = NMFOverlayImage(name: "ic_noArrowLocation")
    
    let view = NMFNaverMapView(frame: .zero)
    
    init(container: DIContainer) {
        self.container = container
        self.humanMarkerView = UserMarkerView(container: container)
        
        super.init()
        view.mapView.isNightModeEnabled = false
        view.mapView.positionMode = .direction
        
        view.mapView.zoomLevel = 15
        view.mapView.minZoomLevel = 5
        view.mapView.maxZoomLevel = 17
        view.mapView.isNightModeEnabled = true
        
        // 사용자 인터페이스 설정
        view.showCompass = false
        view.showScaleBar = false
        view.showZoomControls = false
        view.showLocationButton = true
        
        // 네이버 로고 위치 조정
        view.mapView.logoAlign = .leftBottom
        view.mapView.logoMargin = .init(top: 0, left: 0, bottom: 110, right: 0)
        
        // 틸트 제스처 비활성화
        view.mapView.isTiltGestureEnabled = false
        
        //delegate 설정
        view.mapView.addCameraDelegate(delegate: self)
        view.mapView.touchDelegate = self
        setLocationOverlay()
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
    
    private func setLocationOverlay() {
        let locationOverlay = view.mapView.locationOverlay
        locationOverlay.icon = locationOverlayNoArrowIcon
    }
    
    func checkIfLocationServiceIsEnabled() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self.locationManager = CLLocationManager()
                    self.locationManager?.delegate = self
                    self.locationManager?.startUpdatingLocation()
                    self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                    self.locationManager?.distanceFilter = 15
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
            cameraUpdate.animationDuration = 0.8
            
            let locationOverlay = view.mapView.locationOverlay
            locationOverlay.location = NMGLatLng(lat: userLocation.0, lng: userLocation.1)
            locationOverlay.hidden = false
            
            view.mapView.moveCamera(cameraUpdate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            let location = LocationDTO(latitude: coordinate.latitude, longitude: coordinate.longitude)
           
            container.services.userService.updateLocation(location: location)
                .sink { completion in
                    if case .failure = completion {
                        print("실패")
                    }
                } receiveValue: { _ in
                }.store(in: &subscriptions)
        }
    }
}

// 카메라 관련 이벤트
extension Coordinator: NMFMapViewCameraDelegate {
    // 카메라 움직임이 끝나고 호출되는 콜백 메서드
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        let locationOverlay = view.mapView.locationOverlay
        if locationOverlay.icon != locationOverlayNoArrowIcon {
            setLocationOverlay()
        }
    }
    
    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
        
    }
    
    //지도가 탭 되면 발생하는 이벤트
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        
    }
    
    func moveMapToUserLocation() {
        if let locationManager = locationManager,
           let coordinate = locationManager.location?.coordinate {
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: coordinate.latitude,
                                                                   lng: coordinate.longitude))
            
            DispatchQueue.main.async { [weak self] in
                cameraUpdate.animation = .easeIn
                cameraUpdate.animationDuration = 0.2
                self?.view.mapView.positionMode = .direction
                let locationOverlay = self?.view.mapView.locationOverlay
                locationOverlay?.icon = self!.locationOverlayNoArrowIcon
//                self?.view.mapView.moveCamera(cameraUpdate)
            }
        }
    }
}

// 터치 관련 이벤트
extension Coordinator: NMFMapViewTouchDelegate {
    
}

// 마커
extension Coordinator {
    //    func bind(_ viewModel: MapViewModel) {
    //        viewModel.$userMarkerList
    //            .receive(on: DispatchQueue.main)
    //            .sink { [weak self] userMarkers in
    //                guard let self = self else { return }
    //                self.humanMarkerList.forEach { $0.mapView = nil }
    //                self.humanMarkerList.removeAll()
    //
    //                userMarkers.forEach { userMarker in
    //                    let marker = NMFMarker()
    //                    marker.position = .init(lat: userMarker.lat, lng: userMarker.lng)
    //                    marker.userInfo = ["data": userMarker]
    //                    self.humanMarkerView.configure(userMarker) { image in
    //                        marker.iconImage = NMFOverlayImage(image: image!)
    //                    }
    //                    self.humanMarkerList.append(marker)
    //                }
    //
    //                self.humanMarkerList.forEach {
    //                    if $0.mapView == nil {
    //                        $0.mapView = self.view.mapView
    //                    }
    //                }
    //            }
    //            .store(in: &subscriptions)
    //    }
    func setMarker(markers: [UserMarker]) {
        markers.forEach { [weak self] userMarker in
            let marker = NMFMarker()
            marker.position = .init(lat: userMarker.lat, lng: userMarker.lng)
            marker.userInfo = ["data": userMarker]
            marker.captionAligns = [NMFAlignType.top]
            marker.captionText = userMarker.name
            
            self?.humanMarkerView.configure(userMarker) { image in
                marker.iconImage = NMFOverlayImage(image: image!)
                self?.addMarker(marker)
            }
        }
    }
    
    func addMarker(_ marker: NMFMarker) {
        humanMarkerList.append(marker)
        if marker.mapView == nil {
            marker.mapView = view.mapView
        }
    }
}
    

