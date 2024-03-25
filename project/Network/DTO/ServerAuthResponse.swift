//
//  ServerAuthResponse.swift
//  project
//
//  Created by 최안용 on 3/25/24.
//

import Foundation

struct ServerAuthResponse: Codable {
    var name: String
    var email: String
    var sub: String
}
