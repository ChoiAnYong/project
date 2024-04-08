//
//  projectApp.swift
//  project
//
//  Created by 최안용 on 3/13/24.
//

import SwiftUI

@main
struct projectApp: App {
    @StateObject var container: DIContainer = .init(services: Services())
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AuthenticationView(viewModel: .init(container: container))
                .environmentObject(container)
        }
    }
}
