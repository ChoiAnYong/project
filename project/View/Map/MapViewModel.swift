//
//  MapViewModel.swift
//  project
//
//  Created by 최안용 on 5/7/24.
//

import Foundation
import CoreLocation

final class MapViewModel: ObservableObject {
    @Published var userMarkerList: [UserMarker] = []
    @Published var selectedUser: UserMarker?
    
    enum Action {
        case loadUserMarker([ConnectedUser])
        case moveMapUser
    }
    
    func send(action: Action) {
        switch action {
        case let .loadUserMarker(connectedUser):
            connectedUser.forEach { user in
                let userMarker: UserMarker = .init(id: UUID().hashValue,
                                                   lat: user.latitude!,
                                                   lng: user.longitude!,
                                                   imgUrl: user.profileUrl ?? "",
                                                   name: user.name)
                fetchAddress(for: userMarker)
            }
        case .moveMapUser:
            // TODO: - 클릭된 유저의 위치로 카메라 이동
            break
        }
    }
    
    // 주소 변환
    private func fetchAddress(for userMarker: UserMarker) {
        var marker = userMarker
        let location = CLLocation(latitude: userMarker.lat, longitude: userMarker.lng)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("주소 변환 실패: \(error)")
                return
            }
            guard let placemark = placemarks?.first else {
                print("주소를 찾을 수 없음")
                return
            }
            marker.address = "\(placemark.administrativeArea ?? "") \(placemark.locality ?? "") \(placemark.subLocality ?? "")"
            DispatchQueue.main.async {
                self.userMarkerList.append(marker)
            }
        }
    }
}
