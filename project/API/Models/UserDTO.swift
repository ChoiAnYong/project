//
//  UserObject.swift
//  project
//
//  Created by 최안용 on 3/19/24.
//

import Foundation


struct UserDTO: Codable {
    var name: String
    var profileUrl: String?
    var email: String
    var hasWatch: Bool?
    var location: LocationDTO?
    var connectionMemberDtoList: [OtherDTO]
}


