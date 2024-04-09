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
    func checkAuthentication() async -> String?
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> Void
    func handleSignInWithAppleCompletion(
        _ authorization: ASAuthorization
    ) -> AnyPublisher<ServerAuthResponse, ServiceError>
}

final class AuthenticationService: AuthenticationServiceType {
    private let networkManager: NetworkManagerType
    private let keychainManager: KeychainManager
    private var subscriptions = Set<AnyCancellable>()
    
    init(networkManager: NetworkManagerType, keychainManager: KeychainManager) {
        self.networkManager = networkManager
        self.keychainManager = keychainManager
    }
    
    func checkAuthentication() async -> String? {
        return await networkManager.refreshAccessToken()
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
        print(idTokenString)
        
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
                                            completion: @escaping
                                            (Result<ServerAuthResponse, Error>) -> Void) async {
        await networkManager.request(url: "/login/apple",
                                     method: .POST,
                                     parameters: ["id_token":token.id_token, "name":token.name],
                                     isHTTPHeader: false)
        .sink { result in
            if case .failure = result {
                completion(.failure(AuthenticationError.invalidated))
            }
        } receiveValue: { (response: ServerAuthResponse) in
            Task {
                let accessStatus = await self.keychainManager.creat(KeychainManager.serviceUrl,
                                                                    account:"accessToken",
                                                                    value:response.accessToken)
                let refreshStatus = await self.keychainManager.creat(KeychainManager.serviceUrl,
                                                                     account:"refreshToken",
                                                                     value:response.refreshToken)
                let expiresStatus = await self.keychainManager.creat(KeychainManager.serviceUrl,
                                                                     account:"accessTokenExpiresIn",
                                                                     value: String(response.accessTokenExpiresIn))
                if accessStatus == errSecSuccess &&
                refreshStatus == errSecSuccess &&
                expiresStatus == errSecSuccess {
                    completion(.success(response))
                }
                else {
                    completion(.failure(AuthenticationError.tokenError))
                }
            }
        }.store(in: &subscriptions)
    }
    
}

final class StubAuthenticationService: AuthenticationServiceType {
    func checkAuthentication() async -> String? {
        return ""
    }
    
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> Void {
        
    }
    
    func handleSignInWithAppleCompletion( _ authorization: ASAuthorization)
    -> AnyPublisher<ServerAuthResponse, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}


