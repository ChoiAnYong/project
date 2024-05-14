//
//  UserAlarmViewModel.swift
//  project
//
//  Created by 최안용 on 5/13/24.
//

import Foundation

final class UserAlarmViewModel: ObservableObject {
    
    private let userEmail: String
    private let container: DIContainer
    
    init(userEmail: String, container: DIContainer) {
        self.userEmail = userEmail
        self.container = container
    }
}
