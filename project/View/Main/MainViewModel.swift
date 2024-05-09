//
//  MainViewModel.swift
//  project
//
//  Created by 최안용 on 4/4/24.
//

import Foundation
import Combine

final class MainViewModel: ObservableObject {
    
    enum Action {
        case load
        case presentView
    }

    @Published var myUser: User = .stubUser
    @Published var users: [ConnectedUser] = [.stubConnected1,.stubConnected2]
    @Published var phase: Phase = .success
    
    private var container: DIContainer
    private var subscriptions = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(action: Action) {
        switch action {
        case .load:
            phase = .loading
            container.services.userService.getUser()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    if case .failure = completion {
                        self?.phase = .fail
                    }
                } receiveValue: { [weak self] user in
                    self?.myUser = user.0
                    self?.users = user.1
                    self?.phase = .success                    
                }.store(in: &subscriptions)
            
        case .presentView:
            return
        }
    }
}
