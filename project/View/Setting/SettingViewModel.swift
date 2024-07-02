//
//  SettingViewModel.swift
//  project
//
//  Created by 최안용 on 7/2/24.
//

import Foundation

final class SettingViewModel: ObservableObject {
    enum Action {
        case pop
    }
    
    @Published var sectionItems: [SectionItem] = []
    
    private var container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
        self.sectionItems = [
            .init(label: "모드설정", settings: AppearanceType.allCases.map { .init(item: $0) })
            ]
    }
    
    func send(action: Action) {
        switch action {
        case .pop:
            container.navigationRouter.pop()
        }
    }
}
