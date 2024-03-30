//
//  AuthenticationService.swift
//  project
//
//  Created by 최안용 on 3/18/24.
//

//v6BcIMyJ0FjoEsbnBz71nw_GkmKYjfNO

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
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String
    func handleSignInWithAppleCompletion(
        _ authorization: ASAuthorization,
        nonce: String
    ) -> AnyPublisher<User, ServiceError>
}

final class AuthenticationService: AuthenticationServiceType {
    private var networkManager: NetworkManagerType
    private var subscriptions = Set<AnyCancellable>()
    
    init(networkManager: NetworkManagerType) {
        self.networkManager = networkManager
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        request.requestedScopes = [.fullName, .email]
        
        let nonce = "v6BcIMyJ0FjoEsbnBz71nw_GkmKYjfNO" // 초기
        request.nonce = sha256(nonce)
        return nonce
    }
    
    func handleSignInWithAppleCompletion(
        _ authorization: ASAuthorization,
        nonce: String
    ) -> AnyPublisher<User, ServiceError> {
        Future { [weak self] promise in
            self?.handleSignInWithAppleCompletion(authorization, nonce: nonce) { result in
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
        nonce: String,
        completion: @escaping (Result<User, Error>) -> Void
    )  {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken else {
            completion(.failure(AuthenticationError.tokenError))
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.failure(AuthenticationError.tokenError))
            return
        }
        
        let name = [appleIDCredential.fullName?.familyName, appleIDCredential.fullName?.givenName]
            .compactMap { $0 }
            .joined(separator: "")
        
        let token = AppleLoginToken(id_token: idTokenString, name: name)
        
        authenticateUserWithServer(token: token) { result in
            switch result {
            case let .success(user):
                completion(.success(user))
            case let .failure(error):
                completion(.failure(error)) 
            }
        }
    }
    
    private func authenticateUserWithServer(token: AppleLoginToken,
                                            completion: @escaping (Result<User, Error>) -> Void) {
        networkManager.requestPOSTModel(url: "/apple", parameters: token)
            .sink { result in
                if case .failure = result {
                    completion(.failure(AuthenticationError.invalidated))
                }
            } receiveValue: { (response: ServerAuthResponse) in
                let user = User(id: "", name: "", age: 1)
                completion(.success(user))
            }.store(in: &subscriptions)
    }
    
}

final class StubAuthenticationService: AuthenticationServiceType {
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        return ""
    }
    
    func handleSignInWithAppleCompletion( _ authorization: ASAuthorization, nonce: String) -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}


