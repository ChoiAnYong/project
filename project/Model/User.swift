//
//  User.swift
//  project
//
//  Created by 최안용 on 3/18/24.
//

import Foundation

struct User {
    var id: String
    var name: String
    var age: Int
    
}

extension User {
    static var stub1: User = .init(id: "dskfsdif", name: "최안용", age: 23)
}
