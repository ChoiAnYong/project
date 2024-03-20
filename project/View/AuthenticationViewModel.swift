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
    
    @Published var authenticationState: AuthenticationState = .unAuthenticated
    
    private var container: DIContainer
    private var currentNonce: String?
    private var subscription = Set<AnyCancellable>()
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(action: Action) {
        switch action {
        case .checkAuthenticationState:
            return
        case let .appleLogin(request):
            let nonce = container.services.authService.handleSignInWithAppleRequest(request)
            currentNonce = nonce    
        case let .appleLoginCompletion(result):
            if case let .success(authorization) = result {
                guard let nonce = currentNonce else { return }
                container.services.authService.handleSignInWithAppleCompletion(authorization, none: nonce)
//                    .flatMap { user in
//                        
//                    }
//                    .sink { <#Subscribers.Completion<ServiceError>#> in
//                        <#code#>
//                    } receiveValue: { <#Publishers.FlatMap<(), AnyPublisher<User, ServiceError>>.Output#> in
//                        
//                    }.store(in: &subscription)
            } else if case let .failure(failure) = result {
                
            }
        case .logout:
            return
        }
    }
}
