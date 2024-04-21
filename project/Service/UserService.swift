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
    func getUser() -> AnyPublisher<(User, [User]), ServiceError>
    
}

final class UserService: UserServiceType {
    private var networkManager: Provider
    private var keychainManager: KeychainManager
    
    init(networkManager: Provider, keychainManager: KeychainManager) {
        self.networkManager = networkManager
        self.keychainManager = keychainManager
    }
    
    func getUser() -> AnyPublisher<(User, [User]), ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            guard let token = self.keychainManager.read(account: "accessToken").value else { return }
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
    func getUser() -> AnyPublisher<(User, [User]), ServiceError> {
        Empty().eraseToAnyPublisher()
    }    
}
