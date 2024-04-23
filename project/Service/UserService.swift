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
    
}

final class UserService: UserServiceType {
    private let networkManager: Provider
    private let keychainManager = KeychainManager.shared
    
    init(networkManager: Provider) {
        self.networkManager = networkManager
    }
    
    func getUser() -> AnyPublisher<(User, [ConnectedUser]), ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            guard let token = self.keychainManager.read(account: "accessToken") else { return }
            let endpoint = APIEndpoints.getUser(token: token)
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
}

final class StubUserService: UserServiceType {
    func getUser() -> AnyPublisher<(User, [ConnectedUser]), ServiceError> {
        Empty().eraseToAnyPublisher()
    }    
}
