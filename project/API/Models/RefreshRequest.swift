//
//  RefreshRequest.swift
//  project
//
//  Created by 최안용 on 5/20/24.
//

import Foundation

struct RefreshRequest: Encodable {
    var accessToken: String
    var refreshToken: String
}
