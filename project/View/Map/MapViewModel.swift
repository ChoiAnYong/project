//
//  MapViewModel.swift
//  project
//
//  Created by 최안용 on 4/16/24.
//

import Foundation

final class MapViewModel: ObservableObject {
    private var container: DIContainer
    @Published var users: [User] = []
    
    init(container: DIContainer) {
        self.container = container
    }
    
    enum Action {
        case didTapLocationBtn
    }
    

}
