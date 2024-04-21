//
//  MainViewModel.swift
//  project
//
//  Created by 최안용 on 4/4/24.
//

import Foundation
import Combine

final class MainViewModel: ObservableObject {
    @Published var myUser: User?
    @Published var users: [User] = []
    
    enum Action {
        case getUser
    }
    
    private var container: DIContainer
    private var subscriptions = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(action: Action) {
        switch action {
        case .getUser:
            container.services.userService.getUser()
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure = completion {
                        
                    }                    
                } receiveValue: { [weak self] user in
                    self?.myUser = user.0
                    self?.users = user.1
                }
                .store(in: &subscriptions)
        }
    }
}
