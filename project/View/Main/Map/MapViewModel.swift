//
//  MapViewModel.swift
//  project
//
//  Created by 최안용 on 5/7/24.
//

import Foundation

final class MapViewModel: ObservableObject {
    @Published var userMarkerList: [UserMarker] = []
    
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
                userMarkerList.append(userMarker)
            }
        case .moveMapUser:
            // TODO: - 클릭된 유저의 위치로 카메라 이동
            break
        }
    }
}
