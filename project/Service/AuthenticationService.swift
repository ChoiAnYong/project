//
//  AuthenticationService.swift
//  project
//
//  Created by 최안용 on 3/18/24.
//

import Foundation
import Combine
import AuthenticationServices

enum AuthenticationError: Error {
    case clientIDError
    case tokenError
    case authoCodeError
    case invalidated
}

protocol AuthenticationServiceType {
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest)
    func handleSignInWithAppleCompletion(
        _ authorization: ASAuthorization
    ) -> AnyPublisher<User, ServiceError>
}

final class AuthenticationService: AuthenticationServiceType {
    private var networkManager: NetworkManagerType
    private var token: String?
    private var subscriptions = Set<AnyCancellable>()
    
    init(networkManager: NetworkManagerType) {
        self.networkManager = networkManager
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
    
    func handleSignInWithAppleCompletion(
        _ authorization: ASAuthorization
    ) -> AnyPublisher<User, ServiceError> {
        Future { [weak self] promise in
            self?.handleSignInWithAppleCompletion(authorization) { result in
                switch result {
                case let .success(user):
                    promise(.success(user))
                case let .failure(error):
                    promise(.failure(.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
}

extension AuthenticationService {
    private func handleSignInWithAppleCompletion(
        _ authorization: ASAuthorization,
        completion: @escaping (Result<User, Error>) -> Void
    )  {
        do {
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let appleIDToken = appleIDCredential.identityToken else {
                completion(.failure(AuthenticationError.tokenError))
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                completion(.failure(AuthenticationError.tokenError))
                return
            }
            
//            guard let authorizationCode = appleIDCredential.authorizationCode else {
//                completion(.failure(AuthenticationError.authoCodeError))
//                return
//            }
//            
//            guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else {
//                completion(.failure(AuthenticationError.authoCodeError))
//                return
//            }
            
            
            authenticateUserWithServer(idToken: idTokenString,
                                       completion: authCodeString)
            completion(.success(.init(id: "", name: "", age: 1)))
        }catch {
            completion(.failure(AuthenticationError.invalidated))
        }
        
        
    }
    
    private func authenticateUserWithServer(idToken: String,
                                            completion: @escaping (Result<User, Error>) -> Void) {
        networkManager.requestPOSTModel(url: "/user", parameters: ["id_token": idToken])
            .sink { completion in
                switch completion {
                    
                case .finished:
                    <#code#>
                case .failure(_):
                    <#code#>
                }
            } receiveValue: { [weak self] value in
                self?.token = value
            }.store(in: &subscriptions)

    }
    
}

final class StubAuthenticationService: AuthenticationServiceType {
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
    }
    
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization) -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}
