//
//  AuthenticationViewModel.swift
//  project
//
//  Created by 최안용 on 3/18/24.
//

import Foundation
import Combine
import AuthenticationServices

enum AuthenticationState {
    case unAuthenticated
    case authenticated
}

final class AuthenticationViewModel: ObservableObject {
    enum Action {
        case checkAuthenticationState
        case appleLogin(ASAuthorizationAppleIDRequest)
        case appleLoginCompletion(Result<ASAuthorization, Error>)
        case logout
    }
    
    @Published var isLoading: Bool = false
    @Published var authenticationState: AuthenticationState = .unAuthenticated
    @Published var isDisplayAlert: Bool = false
    

    private var container: DIContainer
    private var subscription = Set<AnyCancellable>()
    private var km = KeychainManager()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(action: Action) {
        switch action {
        case .checkAuthenticationState:
            isLoading = true
            Task {
                await container.services.authService.checkAuthentication { result in
                    switch result {
                    case let .success(success):
                        DispatchQueue.main.async {
                            self.isLoading = false
                            if success == true {
                                self.authenticationState = .authenticated
                            } else {
                                self.authenticationState = .unAuthenticated
                            }
                        }
                    case let .failure(error):
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.authenticationState = .unAuthenticated
                        }
                    }
                }
            }
            
        case let .appleLogin(request): // case의 연관값에 접근하고 싶으면 let
            container.services.authService.handleSignInWithAppleRequest(request)
            
        case let .appleLoginCompletion(result):
            if case let .success(authorization) = result {
                isLoading = true
                container.services.authService.handleSignInWithAppleCompletion(authorization)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        if case .failure = completion {
                            self?.isLoading = false
                        }
                    } receiveValue: { [weak self] response in
                        self?.handleServerAuthResponse(response)
                    }.store(in: &subscription)
            } else if case let .failure(error) = result {
                isLoading = false
                isDisplayAlert = true
                print(error.localizedDescription)
            }
        case .logout:
            return
        }
    }
    
    
    private func handleServerAuthResponse(_ response: ServerAuthResponse) {
        Task {
            let accessStatus = await km.creat(KeychainManager.serviceUrl,
                                              account:"accessToken",
                                              value:response.accessToken)
            let refreshStatus = await km.creat(KeychainManager.serviceUrl,
                                               account:"refreshToken",
                                               value:response.refreshToken)
            let expiresStatus = await km.creat(KeychainManager.serviceUrl,
                                               account:"accessTokenExpiresIn",
                                               value: String(response.accessTokenExpiresIn))
            if accessStatus == errSecSuccess &&
                refreshStatus == errSecSuccess &&
                expiresStatus == errSecSuccess {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.authenticationState = .authenticated
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isDisplayAlert = true
                }
            }
        }
    }
}
