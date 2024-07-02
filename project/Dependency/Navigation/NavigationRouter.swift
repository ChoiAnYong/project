//
//  NavigationRouter.swift
//  project
//
//  Created by 최안용 on 7/2/24.
//

import Foundation
import Combine

protocol NavigationRoutable {
    var destinations: [NavigationDestination] { get set }
    
    func push(to view: NavigationDestination)
    func pop()
    func popToRootView()
}

final class NavigationRouter: NavigationRoutable, ObservableObjectSettable {
    var objectWillChange: ObservableObjectPublisher?
    
    var destinations: [NavigationDestination] = [] {
        didSet {
            objectWillChange?.send()
        }
    }
    
    func push(to view: NavigationDestination) {
        destinations.append(view)
    }
    
    func pop() {
        _ = destinations.removeLast()
    }
    
    func popToRootView() {
        destinations = []
    }
}
