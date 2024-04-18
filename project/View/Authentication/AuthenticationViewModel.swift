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
    case unknownAuthenticated
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
    @Published var authenticationState: AuthenticationState = .authenticated
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
            Task { [weak self] in
                guard let self = self else { return }
                
                let check = await container.services.authService.checkAuthentication()
                DispatchQueue.main.async {
                    self.isLoading = false
                    if check == nil {
                        self.authenticationState = .unAuthenticated
                    } else {
                        self.authenticationState = .authenticated
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
                            self?.authenticationState = .unAuthenticated
                            self?.isDisplayAlert = true
                        }
                    } receiveValue: { [weak self] _ in
                        self?.isLoading = false
                        self?.authenticationState = .authenticated
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
}
