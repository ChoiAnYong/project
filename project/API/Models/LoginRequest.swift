//
//  LoginRequest.swift
//  project
//
//  Created by 최안용 on 5/19/24.
//

import Foundation

struct LoginRequest: Encodable {
    var idToken: String
    var name: String
    var deviceToken: String
}
