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
    private var network: NetworkManagerType
    
    init(network: NetworkManagerType) {
        self.network = network
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
        Task {
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
                print(idTokenString)
                guard let authorizationCode = appleIDCredential.authorizationCode else {
                    completion(.failure(AuthenticationError.authoCodeError))
                    return
                }
                
                guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else {
                    completion(.failure(AuthenticationError.authoCodeError))
                    return
                }
                
                
                try await authenticateUserWithServer(idToken: idTokenString,
                                                     authorizationCode: authCodeString)
                completion(.success(.init(id: "", name: "", age: 1)))
            }catch {
                completion(.failure(AuthenticationError.invalidated))
            }
            
        }
        
    }
    
    private func authenticateUserWithServer(idToken: String,
                                            authorizationCode: String) async throws {
        do {
            try await self.network.requestPOSTWithURLSessionUploadTask(url: "/user",
                                                                   parameters: ["id_token": idToken])
        } catch {
            print(error.localizedDescription)
        }
    }
}

final class StubAuthenticationService: AuthenticationServiceType {
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
    }
    
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization) -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    
}
