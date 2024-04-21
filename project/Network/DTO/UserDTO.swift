//
//  UserObject.swift
//  project
//
//  Created by 최안용 on 3/19/24.
//

import Foundation


struct UserDTO: Codable {
    var name: String
    var thumbnailUrl: String?
    var email: String
    var description: String?
    var latitude: Double?
    var longitude: Double?
    var otherUsers: [OtherDTO]
}

struct OtherDTO: Codable {
    var name: String
    var thumbnailUrl: String?
    var email: String
    var description: String?
    var latitude: Double?
    var longitude: Double?
}

extension UserDTO {
    func toModel() -> (User,[User]) {
        let myUser = User(name: name,
                          thumbnailUrl: thumbnailUrl,
                          email: email,
                          description: description,
                          latitude: latitude,
                          longitude: longitude)
        
        let users = otherUsers.map { otherObject in
            User(name: name,
                 thumbnailUrl: thumbnailUrl,
                 email: email,
                 description: description,
                 latitude: latitude,
                 longitude: longitude)
        }
        return (myUser, users)
    }
}

//extension UserObject {
//    func toModel() -> User {
//        .init(id: id, name: name, age: age)
//    }
//}
