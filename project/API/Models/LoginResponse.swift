//
//  LoginResponse.swift
//  project
//
//  Created by 최안용 on 5/21/24.
//

import Foundation

struct LoginResponse: Decodable {
    var grantType: String
    var accessToken: String
    var refreshToken: String
    var accessTokenExpiresIn: String
}
