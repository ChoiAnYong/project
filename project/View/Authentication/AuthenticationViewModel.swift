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
    
    private var loadDataTask: Task<Void, Never>?
    
    private var container: DIContainer
    private var subscription = Set<AnyCancellable>()
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
                container.services.authService.handleSignInWithAppleCompletion(authorization)
                    
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
