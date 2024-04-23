//
//  User.swift
//  project
//
//  Created by 최안용 on 3/18/24.
//

import Foundation

struct User {
    var name: String
    var profileUrl: String?
    var email: String
    var hasWatch: Bool?
    var latitude: Double?
    var longitude: Double?
    var connectionMemberDtoList: [OtherDTO]?
}

