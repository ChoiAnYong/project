//
//  ServerAuthResponse.swift
//  project
//
//  Created by 최안용 on 3/25/24.
//

import Foundation

struct ServerAuthResponse: Codable {
    var accessToken: String
    var refreshToken: String
    var email: String
    var isRegistered: Bool
}
