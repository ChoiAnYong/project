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
    
    private var loadDataTask: Task<Void, Never>?
    
    private var container: DIContainer
    private var currentNonce: String?
    private var subscription = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(action: Action) {
        switch action {
        case .checkAuthenticationState:
            break
        case let .appleLogin(request): // case의 연관값에 접근하고 싶으면 let
            let nonce = container.services.authService.handleSignInWithAppleRequest(request)
            self.currentNonce = nonce
            
        case let .appleLoginCompletion(result):
            if case let .success(authorization) = result {
                guard let nonce = currentNonce else { return }
                
                container.services.authService.handleSignInWithAppleCompletion(authorization, nonce: nonce)
                    .sink { [weak self] completion in
                        if case .failure = completion {
                            self?.isLoading = false
                        }
                    } receiveValue: { [weak self] user in
                        self?.isLoading = false
                        self?.authenticationState = .authenticated
                        print(user)
                    }.store(in: &subscription)
            } else if case let .failure(error) = result {
                isLoading = false
                print(error.localizedDescription)
            }
        case .logout:
            return
        }
    }
}
