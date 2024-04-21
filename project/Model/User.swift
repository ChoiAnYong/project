//
//  User.swift
//  project
//
//  Created by 최안용 on 3/18/24.
//

import Foundation

struct User: Hashable {
    var name: String
    var thumbnailUrl: String?
    var email: String
    var description: String?
    var latitude: Double?
    var longitude: Double?
}

