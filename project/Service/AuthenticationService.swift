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
    case invalidated
}

protocol AuthenticationServiceType {
    func checkAuthentication() -> Bool
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> Void
    func handleSignInWithAppleCompletion(
        _ authorization: ASAuthorization
    ) -> AnyPublisher<ServerAuthResponse, ServiceError>
}

final class AuthenticationService: AuthenticationServiceType {
    private let networkManager: Provider
    private let keychainManager = KeychainManager.shared
    
    init(networkManager: Provider) {
        self.networkManager = networkManager
    }
    
    func checkAuthentication() -> Bool {
        guard keychainManager.read(account: SaveToken.access.rawValue) != nil else {
            return false
        }
        return true
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
            self?.handleSignInWithAppleCompletion(authorization) { result in
                switch result {
                case let .success(response):
                    promise(.success(response))
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
        completion: @escaping (Result<ServerAuthResponse, Error>) -> Void
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

        let name = [appleIDCredential.fullName?.familyName, appleIDCredential.fullName?.givenName]
            .compactMap { $0 }
            .joined(separator: "")
        
        guard let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") else {
            completion(.failure(AuthenticationError.tokenError))
            return
        }
    
        let token = AppleLoginDTO(idToken: idTokenString,
                                    name: name,
                                    deviceToken: deviceToken)
        
        let endpoint = APIEndpoints.authenticateUser(with: token)
        networkManager.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                if self.keychainManager.creat(account: SaveToken.access.rawValue,
                                              value: response.accessToken) &&
                   self.keychainManager.creat(account: SaveToken.refresh.rawValue, 
                                              value: response.refreshToken){
                    completion(.success(response))
                } else {
                    completion(.failure(AuthenticationError.tokenError))
                }
            case let .failure(error):
                print(error)
                completion(.failure(error))
            }
        }
    }
}

final class StubAuthenticationService: AuthenticationServiceType {
    func checkAuthentication() -> Bool {
        return true
    }
    
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> Void {
        
    }
    
    func handleSignInWithAppleCompletion( _ authorization: ASAuthorization)
    -> AnyPublisher<ServerAuthResponse, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}


