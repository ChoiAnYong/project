//
//  DIContainer.swift
//  project
//
//  Created by 최안용 on 3/18/24.
//

import Foundation

final class DIContainer: ObservableObject {
    var services: ServiceType
    var navigationRouter: NavigationRoutable & ObservableObjectSettable
    var appearanceController: AppearanceController & ObservableObjectSettable
    
    init(services: ServiceType,
         navigationRouter: NavigationRoutable & ObservableObjectSettable = NavigationRouter(),
         appearanceController: AppearanceController & ObservableObjectSettable = AppearanceController()) {
        self.services = services
        self.navigationRouter = navigationRouter
        self.appearanceController = appearanceController
        
        self.navigationRouter.setObjectWillChange(objectWillChange)
        self.appearanceController.setObjectWillChange(objectWillChange)
    }
}

extension DIContainer {
    static var stub: DIContainer {
        .init(services: StubService())
    }
}
