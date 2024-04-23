//
//  ConnectedUser.swift
//  project
//
//  Created by 최안용 on 4/22/24.
//

import Foundation

struct ConnectedUser: Hashable {
    var name: String
    var email: String
    var profileUrl: String?
    var latitude: Double?
    var longitude: Double?
}
