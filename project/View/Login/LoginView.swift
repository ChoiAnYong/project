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
        VStack {
            Image("icon")
                .resizable()
                .frame(width: 90, height: 90)
                .padding(.bottom, 50)
            
//            Button(action: {
//                viewModel.send(action: .checkAuthenticationState)
//            }, label: {
//                Text("네트워크 테스트")
//            })

            
            SignInWithAppleButton { request in
                viewModel.send(action: .appleLogin(request))
            } onCompletion: { completion in
                viewModel.send(action: .appleLoginCompletion(completion))
            }
            .frame(width: 200, height: 38)
            .signInWithAppleButtonStyle(.whiteOutline)
        }
    }
}

#Preview {
    LoginView()
}
