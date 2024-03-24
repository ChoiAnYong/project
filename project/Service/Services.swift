//
//  Services.swift
//  project
//
//  Created by 최안용 on 3/18/24.
//

import Foundation

protocol ServiceType {
    var authService: AuthenticationServiceType { get set }
}

final class Services: ServiceType {
    var authService: AuthenticationServiceType
    
    init() {
        self.authService = AuthenticationService(networkManager: NetworkManager())
    }
}

final class StubService: ServiceType {
    var authService: AuthenticationServiceType = StubAuthenticationService()
}
