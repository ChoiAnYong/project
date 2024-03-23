//
//  UserObject.swift
//  project
//
//  Created by 최안용 on 3/19/24.
//

import Foundation


struct UserObject: Codable {
    var users: [UserInfo]
}

extension UserObject {

    struct UserInfo: Codable {
        var id: Int
        var title: String
    }
}


//extension UserObject {
//    func toModel() -> User {
//        .init(id: id, name: name, age: age)
//    }
//}
