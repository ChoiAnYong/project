//
//  AuthenticationViewModel.swift
//  project
//
//  Created by 최안용 on 3/18/24.
//

import AuthenticationServices
import Combine
import Foundation

enum AuthenticationState {
    case unAuthenticated
    case authenticated
}

final class AuthenticationViewModel: ObservableObject {
    enum Action {
        case checkAuthenticationState
        case appleLogin(ASAuthorizationAppleIDRequest)
        case appleLoginCompletion(Result<ASAuthorization, Error>)
        case invalidate
        case logout
    }
    
    @Published var isLoading: Bool = false
    @Published var authenticationState: AuthenticationState = .unAuthenticated
    @Published var isDisplayAlert: Bool = false
    

    private var container: DIContainer
    private var subscription = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        setupInvalidateHandling()
    }
    
    func send(action: Action) {
        switch action {
        case .checkAuthenticationState:
            isLoading = true
            if container.services.authService.checkAuthentication() {
                isLoading = false
                authenticationState = .authenticated
            } else {
                isLoading = false
                authenticationState = .unAuthenticated
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
            logout()
        case .invalidate:
            invalidate()
        }
    }
    
    private func logout() {
        if KeychainManager.shared.delete(account: SaveToken.access.rawValue),
           KeychainManager.shared.delete(account: SaveToken.refresh.rawValue) {
            authenticationState = .unAuthenticated
        }
    }
    
    private func invalidate() {
        logout()
    }
    
    private func setupInvalidateHandling() {
        NotificationCenter.default.publisher(for: .init("401Error"))
            .sink { [weak self] _ in
                self?.send(action: .invalidate)
            }
            .store(in: &subscription)
    }
}
