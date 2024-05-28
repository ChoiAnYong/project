//
//  MapViewModel.swift
//  project
//
//  Created by 최안용 on 5/7/24.
//

import Foundation
import CoreLocation
import PhotosUI
import SwiftUI

@MainActor
final class MapViewModel: ObservableObject {
    @Binding var user: User?
    @Published var userMarkerList: [UserMarker] = []
    @Published var myMarker: UserMarker?
    @Published var imageSelection: PhotosPickerItem? {
        didSet {
            Task {
                await updateProfileImage(pickerItem: imageSelection)
            }
        }
    }
    
    private var container: DIContainer
    
    init(container: DIContainer, user: Binding<User?>) {
        self.container = container
        self._user = user
    }
    
    enum Action {
        case loadUserMarker(User, [ConnectedUser])
    }
    
    func send(action: Action) async {
        switch action {
        case let .loadUserMarker(user, connectedUser):
            Task { [weak self] in
                do {
                    self?.myMarker = .init(id: UUID().hashValue,
                                           lat: user.latitude ?? 0,
                                           lng: user.longitude ?? 0,
                                           imgUrl: user.profileUrl,
                                           name: user.name,
                                           myMarker: true)
                    
                    self?.userMarkerList.removeAll()
                    try await connectedUser.asyncForEach { user in
                        var userMarker: UserMarker = .init(id: UUID().hashValue,
                                                           lat: user.latitude ?? 0,
                                                           lng: user.longitude ?? 0,
                                                           imgUrl: user.profileUrl ?? "",
                                                           name: user.name)
                        userMarker.address = try await self?.fetchAddress(lat: userMarker.lat, lng: userMarker.lng)
                        self?.userMarkerList.append(userMarker)
                    }
                } catch {
                    return
                }
            }
        }
    }
    
    func updateProfileImage(pickerItem: PhotosPickerItem?) async {
        guard let pickerItem else { return }
        
        do {
            let data = try await container.services.photoPickerService.loadTransferable(from: pickerItem)
            let url = try await container.services.uploadService.uploadImage(data: data)
            user?.profileUrl = url?.absoluteString
            myMarker?.imgUrl = url?.absoluteString
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // 주소 변환
    private func fetchAddress(lat: Double, lng: Double) async throws -> String {
        var resultString: String
        let location = CLLocation(latitude: lat, longitude: lng)
        let placemarker = try await CLGeocoder().reverseGeocodeLocation(location).first
        
        resultString = "\(placemarker?.administrativeArea ?? "") \(placemarker?.locality ?? "") \(placemarker?.subLocality ?? "")"
        return resultString
        
        
//        { placemarks, error in
//            if let error = error {
//                print("주소 변환 실패: \(error)")
//                return
//            }
//            guard let placemark = placemarks?.first else {
//                print("주소를 찾을 수 없음")
//                return
//            }
//            marker.address = "\(placemark.administrativeArea ?? "") \(placemark.locality ?? "") \(placemark.subLocality ?? "")"
//            
//            DispatchQueue.main.async {
//                self.userMarkerList.append(marker)
//            }
//        }
    }
}

extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return from.distance(from: to)
    }
}
