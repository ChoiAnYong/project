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
            Image("icon")
                .resizable()
                .frame(width: 90, height: 90)
                .padding(.bottom, 50)
            

            
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
    AuthenticationView(viewModel: .init(container: .init(services: StubService())))
}
