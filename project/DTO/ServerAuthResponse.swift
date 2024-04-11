//
//  ServerAuthResponse.swift
//  project
//
//  Created by 최안용 on 3/25/24.
//

import Foundation

struct ServerAuthResponse: Codable {
    var grantType: String
    var accessToken: String
    var refreshToken: String    
    var accessTokenExpiresIn: Int64
}
