//
//  LoginView.swift
//  project
//
//  Created by 최안용 on 3/20/24.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject private var viewModel: AuthenticationViewModel
    
    var body: some View {
        ZStack {
            Color.appOrange
            
            Image("Icon")
                .resizable()
                .frame(width: 200, height: 200)
                .padding(.top, 11)
            
            VStack {
                Spacer()
                SignInWithAppleButton { request in
                    viewModel.send(action: .appleLogin(request))
                } onCompletion: { completion in
                    viewModel.send(action: .appleLoginCompletion(completion))
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .signInWithAppleButtonStyle(.black)
                .padding(.bottom, 40)
                .padding(.horizontal, 30)
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingView()
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel(container: .init(services: StubService())))
}
