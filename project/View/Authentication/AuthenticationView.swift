//
//  AuthenticationView.swift
//  project
//
//  Created by 최안용 on 3/13/24.
//

import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @StateObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        VStack {
            switch viewModel.authenticationState {
            case .unAuthenticated:
                LoginView()
                    .environmentObject(viewModel)
            case .authenticated:
                MapView(pathModel: PathModel())
            }
        }
        .onAppear {
            viewModel.send(action: .checkAuthenticationState)
        }
    }
}

#Preview {
    AuthenticationView(viewModel: .init(container: .init(services: StubService())))
}
