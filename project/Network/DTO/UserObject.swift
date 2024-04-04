//
//  UserObject.swift
//  project
//
//  Created by 최안용 on 3/19/24.
//

import Foundation


struct UserObject: Codable {
    var name: String
    var image: Data
    var email: String
    var hasWatch: Bool
    var connectionMemberList: [String]
}

//extension UserObject {
//    func toModel() -> User {
//        .init(id: id, name: name, age: age)
//    }
//}
