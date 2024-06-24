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
    @EnvironmentObject var container: DIContainer
    
    
    var body: some View {
        VStack {
            switch viewModel.authenticationState {
            case .unAuthenticated:
                LoginView()
                    .environmentObject(viewModel)
                
            case .authenticated:
                MainView(pathModel: PathModel(), viewModel: MainViewModel(container: container))
            }
        }
        .onAppear {
//            viewModel.send(action: .checkAuthenticationState)
        }
        .alert("로그인 시간이 만료되어 로그아웃 되었습니다.", isPresented: $viewModel.isDisplayAlert) {
            Button("확인", action: {})
        }
    }
}

#Preview {
    AuthenticationView(viewModel: .init(container: DIContainer(services: StubService())))
        .environmentObject(DIContainer(services: StubService()))
}
