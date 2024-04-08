//
//  User.swift
//  project
//
//  Created by 최안용 on 3/18/24.
//

import Foundation

struct User {
    var name: String
    var email: String
    var descriptino: String?
    
}

extension User {
    static var stub1: User = .init(name: "최안용", email: "dksdyd78@naver.com", descriptino: "씨발")
}
