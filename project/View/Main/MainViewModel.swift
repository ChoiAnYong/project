//
//  MainViewModel.swift
//  project
//
//  Created by 최안용 on 4/4/24.
//

import Foundation
import Combine
import UIKit

final class MainViewModel: ObservableObject {
    
    enum Action {
        case load
        case presentView(MainModalDestination)
        case call
    }

    @Published var myUser: User?
    @Published var users: [ConnectedUser] = []
    @Published var phase: Phase = .notRequested
    @Published var modalDestination: MainModalDestination?
    
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
            
        case let .presentView(destination):
            modalDestination = destination
        case .call:
            let urlString = "tel://" + "010-3622-4431"
            if let numberURL = NSURL(string: urlString),
               UIApplication.shared.canOpenURL(numberURL as URL) {
                UIApplication.shared.open(numberURL as URL, options: [:], completionHandler: nil)
            }
            
        }
    }
}
