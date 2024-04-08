//
//  SheetViewModel.swift
//  project
//
//  Created by 최안용 on 4/8/24.
//

import Foundation

final class SheetViewModel: ObservableObject {
    @Published var user: User = .stub1
    @Published var users: [User] = [.stub2, .stub3, .stub4, .stub5]
    
    private var container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    
}
