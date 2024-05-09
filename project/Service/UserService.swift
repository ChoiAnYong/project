//
//  UserService.swift
//  project
//
//  Created by 최안용 on 4/4/24.
//

import Foundation
import Combine


enum UserServiceError: Error {
    case error
    case tokenError
}

protocol UserServiceType {
    func getUser() -> AnyPublisher<(User, [ConnectedUser]), ServiceError>
    func updateLocation(location: LocationDTO) -> AnyPublisher<Void, ServiceError>
}

final class UserService: UserServiceType {
    private let networkManager: Provider
    
    init(networkManager: Provider) {
        self.networkManager = networkManager
    }
    
    func getUser() -> AnyPublisher<(User, [ConnectedUser]), ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            let endpoint = APIEndpoints.getUser()
            networkManager.request(with: endpoint) { result in
                switch result {
                case let .success(response):
                    promise(.success(response.toModel()))
                case let .failure(error):
                    promise(.failure(.error(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateLocation(location: LocationDTO) -> AnyPublisher<Void, ServiceError> {
        Future<Void, ServiceError> { [weak self] promise in
            guard let self = self else { return }
            let endpoint = APIEndpoints.updateInfo(with: location, path: "/member/gps")
            networkManager.request(with: endpoint) { result in
                switch result {
                case .success(_):
                    promise(.success(()))
                case let .failure(error):
                    promise(.failure(.error(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

final class StubUserService: UserServiceType {
    func getUser() -> AnyPublisher<(User, [ConnectedUser]), ServiceError> {
        return Just((.stubUser, [.stubConnected1, .stubConnected2])).setFailureType(to: ServiceError.self).eraseToAnyPublisher()
    }
    
    func updateLocation(location: LocationDTO) -> AnyPublisher<Void, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}
