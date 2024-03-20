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
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String
    func handleSignInWithAppleCompletion(
        _ authorization: ASAuthorization,
        none: String
    ) -> AnyPublisher<User, ServiceError>
}

final class AuthenticationService: AuthenticationServiceType {
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        return nonce
    }
    
    func handleSignInWithAppleCompletion(
        _ authorization: ASAuthorization,
        none: String
    ) -> AnyPublisher<User, ServiceError> {
        Future { [weak self] promise in
            self?.handleSignInWithAppleCompletion(authorization, nonce: none) { result in
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
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken else {
            completion(.failure(AuthenticationError.tokenError))
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.failure(AuthenticationError.tokenError))
            return
        }
        
        guard let authorizationCode = appleIDCredential.authorizationCode else {
            completion(.failure(AuthenticationError.authoCodeError))
            return
        }
        
        guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else {
            completion(.failure(AuthenticationError.authoCodeError))
            return
        }
        
        //authenticateUserWithServer 호출
    }
    
    private func authenticateUserWithServer(idToken: String,
                                            authorizationCode: String,
                                            completion: @escaping (Result<User,Error>) -> Void) {
        //서버로 정보 보내서 인증하는 로직
    }
}

final class StubAuthenticationService: AuthenticationServiceType {
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        return ""
    }
    
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, 
                                         none: String) -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    
}
