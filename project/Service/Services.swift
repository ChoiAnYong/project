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
//    var pushNotificationService: PushNotificationServiceType { get set }
}

final class Services: ServiceType {
    private let networkManager: Provider
    var authService: AuthenticationServiceType
    var userService: UserServiceType
//    var pushNotificationService: PushNotificationServiceType
    
    init() {
        self.networkManager = ProviderImpl()
        self.authService = AuthenticationService(networkManager: networkManager)
        self.userService = UserService(networkManager: networkManager)
//        self.pushNotificationService = PushNotificationService()
    }
}

final class StubService: ServiceType {
    var authService: AuthenticationServiceType = StubAuthenticationService()
    var userService: UserServiceType = StubUserService()
//    var pushNotificationService: PushNotificationServiceType = StubPushNotificationService()
}
