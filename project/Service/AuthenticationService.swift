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
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> Void
    func handleSignInWithAppleCompletion(
        _ authorization: ASAuthorization
    ) -> AnyPublisher<ServerAuthResponse, ServiceError>
}

final class AuthenticationService: AuthenticationServiceType {
    private var networkManager: NetworkManagerType
    private var subscriptions = Set<AnyCancellable>()
    
    init(networkManager: NetworkManagerType) {
        self.networkManager = networkManager
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> Void {
        request.requestedScopes = [.fullName, .email]
        let nonce = "v6BcIMyJ0FjoEsbnBz71nw_GkmKYjfNO" // 초기
        request.nonce = sha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(
        _ authorization: ASAuthorization
    ) -> AnyPublisher<ServerAuthResponse, ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            Task {
                await self.handleSignInWithAppleCompletion(authorization) { result in
                    switch result {
                    case let .success(response):
                        promise(.success(response))
                    case let .failure(error):
                        promise(.failure(.error(error)))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

}

extension AuthenticationService {
    private func handleSignInWithAppleCompletion(
        _ authorization: ASAuthorization,
        completion: @escaping (Result<ServerAuthResponse, Error>) -> Void
    ) async  {
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
        
        await authenticateUserWithServer(token: token) { result in
            switch result {
            case let .success(response):
                completion(.success(response))
            case let .failure(error):
                completion(.failure(error)) 
            }
        }
    }
    
    private func authenticateUserWithServer(token: AppleLoginToken,
                                            completion: @escaping (Result<ServerAuthResponse, Error>) -> Void) async {
        await networkManager.request(url: "/login/apple", method: .POST, parameters: ["id_token":token.id_token, "name":token.name], isHTTPHeader: false)
            .sink { result in
                if case .failure = result {
                    completion(.failure(AuthenticationError.invalidated))
                }
            } receiveValue: { (response: ServerAuthResponse) in
                
                completion(.success(response))
            }.store(in: &subscriptions)
    }
    
}

final class StubAuthenticationService: AuthenticationServiceType {    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> Void {
        
    }
    
    func handleSignInWithAppleCompletion( _ authorization: ASAuthorization) -> AnyPublisher<ServerAuthResponse, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}


