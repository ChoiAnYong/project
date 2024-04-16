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
}

protocol UserServiceType {
    func getUser() -> AnyPublisher<UserObject, ServiceError>
    
}

final class UserService: UserServiceType {
    private var networkManager: NetworkManagerType
    private var subscriptions = Set<AnyCancellable>()
    
    init(networkManager: NetworkManagerType) {
        self.networkManager = networkManager
    }
    
    func getUser() -> AnyPublisher<UserObject, ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            Task {
                await self.handleNetworkCompletion(url: "/member/info",
                                                   method: .GET,
                                                   parameter: nil,
                                                   isHTTPHeader: true)
                { (result: Result<UserObject, Error>) in
                    switch result {
                    case let .success(response):
                        promise(.success(response))
                    case let .failure(error):
                        promise(.failure(.error(error)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension UserService {
    private func handleNetworkCompletion<T: Decodable>(url: String,
                                                       method: HTTPMethod,
                                                       parameter: [String: String]?,
                                                       isHTTPHeader: Bool ,
                                                       completion: @escaping (Result<T, Error>) -> Void) async
    {
        await networkManager.request(url: url, method: method, parameters: parameter, isHTTPHeader: isHTTPHeader)
            .sink { result in
                if case .failure = result {
                    completion(.failure(UserServiceError.error))
                }
            } receiveValue: { (response: T) in
                completion(.success(response))
            }.store(in: &subscriptions)
        
    }
}

final class StubUserService: UserServiceType {
    func getUser() -> AnyPublisher<UserObject, ServiceError> {
        Empty().eraseToAnyPublisher() 
    }    
}
