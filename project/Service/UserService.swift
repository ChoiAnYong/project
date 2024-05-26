//
//  UserService.swift
//  project
//
//  Created by 최안용 on 4/4/24.
//

import Foundation
import Combine
import Alamofire


enum UserServiceError: Error {
    case error
    case tokenError
}

protocol UserServiceType {
    func getUser() -> AnyPublisher<(User, [ConnectedUser]), ServiceError>
    func updateLocation(location: LocationDTO) -> AnyPublisher<String, ServiceError>
}

final class UserService: UserServiceType {
    func getUser() -> AnyPublisher<(User, [ConnectedUser]), ServiceError> {
        
        return ApiClient.shared.session
            .request(UserRouter.getUser, 
                     interceptor: Interceptor(interceptors: [BaseInterceptor.shared,
                                                             AuthInterceptor.shared]))
            .publishDecodable(type: GetUserResponse.self)
            .value()
            .map { receivedValue in
                return receivedValue.toModel()
            }
            .mapError({ error in
                return ServiceError.error(error)
            })
            .eraseToAnyPublisher()
    }
    
    func updateLocation(location: LocationDTO) -> AnyPublisher<String, ServiceError> {
        
        return ApiClient.shared.session
            .request(UserRouter.updateLocation(location), 
                     interceptor: Interceptor(interceptors: [BaseInterceptor.shared,
                                                             AuthInterceptor.shared]))
            .publishString()
            .value()
            .map { receivedValue in
                return receivedValue
            }
            .mapError({ error in
                return ServiceError.error(error)
            })
            .eraseToAnyPublisher()
    }
}

final class StubUserService: UserServiceType {
    func getUser() -> AnyPublisher<(User, [ConnectedUser]), ServiceError> {
        return Just((.stubUser, [.stubConnected1, .stubConnected2])).setFailureType(to: ServiceError.self).eraseToAnyPublisher()
    }
    
    func updateLocation(location: LocationDTO) -> AnyPublisher<String, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}
