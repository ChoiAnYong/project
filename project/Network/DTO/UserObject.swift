//
//  UserObject.swift
//  project
//
//  Created by 최안용 on 3/19/24.
//

import Foundation

struct UserObject: Codable {
    var id: String
    var name: String
    var age: Int
}

extension UserObject {
    func toModel() -> User {
        .init(id: id, name: name, age: age)
    }
}
