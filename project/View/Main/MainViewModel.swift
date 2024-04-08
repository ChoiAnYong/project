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
        case getUser
    }
    
    private var container: DIContainer
    private var sub = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(action: Action) {
        switch action {
        case .getUser:
            container.services.userService.getUser()
                .sink { completion in
                    switch completion {
                        
                    case .finished:
                        print("성공")
                    case .failure(_):
                        print("실패")
                    }
                    
                } receiveValue: { user in
                    print(user)
                }
                .store(in: &sub)
        }
    }
}
