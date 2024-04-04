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
    
    private var container: DIContainer
    private var subscription = Set<AnyCancellable>()
    private var km = KeychainManager()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(action: Action) {
        switch action {
        case .checkAuthenticationState:
            break
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
                print(error.localizedDescription)
            }
        case .logout:
            return
        }
    }
    
    
    private func handleServerAuthResponse(_ response: ServerAuthResponse) {
        Task {
            let a = await km.creat(KeychainManager.serviceUrl, account:"accessToken", value:response.accessToken)
            let b = await km.creat(KeychainManager.serviceUrl, account:"refreshToken", value:response.refreshToken)
            if a == noErr && b == noErr {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.authenticationState = .authenticated
                }
            }
        }
    }
}
