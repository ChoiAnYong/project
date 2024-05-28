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
    @Published var userLocation: (Double, Double) = (0.0, 0.0) {
        didSet {
            if userLocation.0 != 0.0 && userLocation.1 != 0.0 {
                let location: LocationDTO = .init(latitude: userLocation.0, longitude: userLocation.1)
                
                container.services.userService.updateLocation(location: location)
                    .sink { result in
                        print(result)
                    } receiveValue: { _ in
                    }.store(in: &subscriptions)
            }
        }
    }
    
    // 클릭된 마커
    @Published var selectedUser: UserMarker?
    
    // 현재 스크롤뷰 셀에 해당되는 마커
    @Published var centerVisibleUser: UserMarker? {
        didSet {
            if let user = centerVisibleUser, centerVisibleUser != oldValue {
                moveCellUserLocation(user)
            }
        }
    }
    // 연동된 계정 마커
    var humanMarkerList: [NMFMarker] = []
    
    private var subscriptions = Set<AnyCancellable>()
    private var locationManager: CLLocationManager?
    private var container: DIContainer
    private var humanMarkerView: UserMarkerView
    
    private let locationOverlayIcon = NMFOverlayImage(name: "ic_location")
    private let locationOverlayNoArrowIcon = NMFOverlayImage(name: "ic_noArrowLocation")
    
    lazy var touchHandler =  { (overlay : NMFOverlay) -> Bool in
        let userInfo = overlay.userInfo
        let data = userInfo["data"] as! UserMarker
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: data.lat, lng: data.lng), zoomTo: 15)
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 0.5
        self.selectedUser = data
        self.view.mapView.moveCamera(cameraUpdate)
        return true
    }
    
    let view = NMFNaverMapView(frame: .zero)
    
    init(container: DIContainer) {
        print("Coordinator init")
        self.container = container
        self.humanMarkerView = UserMarkerView(container: container)
        
        super.init()
        view.mapView.zoomLevel = 15
        view.mapView.minZoomLevel = 5
        view.mapView.isNightModeEnabled = false
        
        // 사용자 인터페이스 설정
        view.showCompass = false
        view.showScaleBar = false
        view.showZoomControls = false
        view.showLocationButton = false
        
        // 네이버 로고 위치 조정
        view.mapView.logoAlign = .leftBottom
        view.mapView.logoMargin = .init(top: 0, left: 0, bottom: 180, right: 0)
        
        // 틸트 제스처 비활성화
        view.mapView.isTiltGestureEnabled = false
        
        //delegate 설정
        view.mapView.addCameraDelegate(delegate: self)
        view.mapView.touchDelegate = self
        
        observePositionModeChanges()
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            checkIfLocationServiceIsEnabled()
        case .restricted:
            print("위치 정보 접근이 제한되었습니다.")
        case .denied:
            print("위치 정보 접근을 거절했습니다. 설정에서 변경하세요.")
        case .authorizedAlways, .authorizedWhenInUse:
            print("Success")
            setPositionMode(mode: .direction)
            
        @unknown default:
            break
        }
    }
    
    // 카메라가 direction 모드일 경우
    private func setDirectionLocationOverlay() {
        let locationOverlay = view.mapView.locationOverlay
        locationOverlay.icon = locationOverlayIcon
    }
    
    // 카메라가 normal 모드일 경우
    private func setNormalLocationOverlay() {
        let locationOverlay = view.mapView.locationOverlay
        locationOverlay.icon = locationOverlayNoArrowIcon
    }
    
    
    
    // MARK: - positionMode에 따른 오버레이 관련
    private func observePositionModeChanges() {
        view.mapView.addObserver(self, forKeyPath: "positionMode", options: [.new, .old], context: nil)
        
    }
    
    //positionMode가 변경될 때 호출
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "positionMode", object is NMFMapView {
            DispatchQueue.main.async { [weak self] in
                self?.updateStateName()
            }
        }
    }
    
    private func updateStateName() {
        let stateStr: String
        switch view.mapView.positionMode {
        case .normal:
            stateStr = "NoFollow"
            setNormalLocationOverlay()
        case .direction:
            stateStr = "Follow"
            setDirectionLocationOverlay()
        default:
            stateStr = "otherAction"
        }
        print("Position Mode: \(stateStr)")
    }
    
    func checkIfLocationServiceIsEnabled() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self.locationManager = CLLocationManager()
                    self.locationManager?.delegate = self
                    
                    if self.locationManager?.delegate == nil {
                        self.locationManager?.startUpdatingLocation()
                    }
                    
                    self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                    self.locationManager?.distanceFilter = 15
                    self.checkLocationAuthorization()
                    self.userLocation = self.fetchUserLocation()
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
    func fetchUserLocation() -> (Double, Double) {
        let userLocation = locationManager?.location?.coordinate
        return (userLocation?.latitude ?? 0, userLocation?.longitude ?? 0)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        self.userLocation = (newLocation.coordinate.latitude, newLocation.coordinate.longitude)
    }
}

// 카메라 관련 이벤트
extension Coordinator: NMFMapViewCameraDelegate {
    // 카메라 움직임이 끝나고 호출되는 콜백 메서드
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        
    }
    
    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
        
    }
    
    //지도가 탭 되면 발생하는 이벤트
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        
    }

    func moveCellUserLocation(_ user: UserMarker) {
        var cameraUpdate: NMFCameraUpdate
        if let check = user.myMarker, check == true {
            cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: userLocation.0, lng: userLocation.1), zoomTo: 14)
        } else {
            cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: user.lat, lng: user.lng), zoomTo: 14)
        }
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 0.5
        
        DispatchQueue.main.async { [weak self] in
            guard let selected = self?.selectedUser else {
                self?.view.mapView.moveCamera(cameraUpdate)
                return
            }
            if selected.id == user.id {
                self?.view.mapView.moveCamera(cameraUpdate)
                self?.selectedUser = nil
            }
        }
    }
}

// 터치 관련 이벤트
extension Coordinator: NMFMapViewTouchDelegate {
    
}

// 마커
extension Coordinator {
    func setMarker(markers: [UserMarker]) {
        markers.forEach { [weak self] userMarker in
            let marker = NMFMarker()
            marker.position = .init(lat: userMarker.lat, lng: userMarker.lng)
            marker.touchHandler = self?.touchHandler
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
    
    
    func setPositionMode(mode: NMFMyPositionMode) {
        view.mapView.positionMode = mode
        switch mode {
        case .direction:
            setDirectionLocationOverlay()
        default:
            setNormalLocationOverlay()
        }
    }
}


