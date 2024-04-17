//
//  MapViewModel.swift
//  project
//
//  Created by 최안용 on 4/16/24.
//

import Foundation

final class MapViewModel: ObservableObject {
    private var container: DIContainer
    @Published var users: [User] = [.stub1, .stub2, .stub3, .stub4, .stub5, .stub6]
    
    init(container: DIContainer) {
        self.container = container
    }
    
    
}
