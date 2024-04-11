//
//  AuthToken.swift
//  project
//
//  Created by 최안용 on 3/24/24.
//

import Foundation

struct AppleLoginToken: Codable {
    var idToken: String
    var name: String
    var deviceToken: String
}


