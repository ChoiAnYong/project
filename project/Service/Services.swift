//
//  Services.swift
//  project
//
//  Created by 최안용 on 3/18/24.
//

import Foundation

protocol ServiceType {
    var authService: AuthenticationServiceType { get set }
    var userService: UserServiceType { get set }
}

final class Services: ServiceType {
    private let keychainManager: KeychainManager
    private let networkManager: NetworkManager
    var authService: AuthenticationServiceType
    var userService: UserServiceType
    
    init() {
        self.keychainManager = KeychainManager()
        self.networkManager = NetworkManager(tokenManager: keychainManager)
        self.authService = AuthenticationService(networkManager: networkManager, keychainManager: keychainManager)
        self.userService = UserService(networkManager: networkManager)
    }
}

final class StubService: ServiceType {
    var authService: AuthenticationServiceType = StubAuthenticationService()
    var userService: UserServiceType = StubUserService()
}
