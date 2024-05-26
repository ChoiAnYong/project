//
//  AuthInterceptor.swift
//  project
//
//  Created by 최안용 on 5/22/24.
//

import Foundation
import Alamofire

class AuthInterceptor: RequestInterceptor {
    static let shared: AuthenticationInterceptor<OAuthAuthenticator> = {
            guard let access = KeychainManager.shared.read(account: SaveToken.access.rawValue),
                  let refresh = KeychainManager.shared.read(account: SaveToken.refresh.rawValue) else {
                fatalError("토큰을 읽어올 수 없습니다.")
            }

            let credential = OAuthCredential(accessToken: access,
                                             refreshToken: refresh,
                                             expiration: Date(timeIntervalSinceNow: 60 * 60))
            
            let authenticator = OAuthAuthenticator()
            let interceptor = AuthenticationInterceptor(authenticator: authenticator, credential: credential)
            
            return interceptor
        }()
}

