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
    var emgState: Bool
}

extension ConnectedUser {
    static var stubConnected1: ConnectedUser {
        .init(name: "이찬희", email: "lee@naver.com", profileUrl: "https://firebasestorage.googleapis.com/v0/b/lmessenger-d0f09.appspot.com/o/41E08E5B-37E8-4335-B405-E44AA4944C4A_1_105_c.jpeg?alt=media&token=94a79810-7f80-4564-bcba-6919453b8ad4", latitude: 36.9791, longitude: 126.9222, emgState: false)
    }
    
    static var stubConnected2: ConnectedUser {
        .init(name: "이준석", email: "이준석@gmail.com", profileUrl: "https://firebasestorage.googleapis.com/v0/b/lmessenger-d0f09.appspot.com/o/Users%2FJTBTBtT24HckerXzUUhIStw72U52%2F055F4CC8-B854-4C7F-ADD1-4DC8BB80DBE9?alt=media&token=281e822e-24cc-4b3b-858f-3275c16b5230", latitude: 36.7745, longitude: 126.9338, emgState: false)
    }
    
    static var stubConnected3: ConnectedUser {
        .init(name: "이광혁", email: "이준석@gmail.com", latitude: 37.7745, longitude: 126.9338, emgState: false)
    }
}
