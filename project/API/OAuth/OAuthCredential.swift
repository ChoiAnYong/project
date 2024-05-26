//
//  OAuthCredential.swift
//  project
//
//  Created by 최안용 on 5/21/24.
//

import Foundation
import Alamofire

struct OAuthCredential: AuthenticationCredential {
    let accessToken: String
    
    let refreshToken: String
    
    let expiration: Date
    
    // Require refresh if within 5 minutes of expiration
    var requiresRefresh: Bool { false }
}
