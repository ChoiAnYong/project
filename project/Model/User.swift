//
//  User.swift
//  project
//
//  Created by 최안용 on 3/18/24.
//

import Foundation

struct User: Hashable {
    var name: String
    var email: String
    var descriptino: String?
    var latitude: Double
    var longitude: Double
    
}

extension User {
    static var stub1: User = .init(name: "홍길동", email: "dksdyd78@naver.com", descriptino: "씨발", latitude: 36.979278564453125, longitude: 126.92241151386197)
    static var stub2: User = .init(name: "김철수", email: "@naver.com", descriptino: "짜증나", latitude: 36.979278564463125, longitude: 126.92241151386497)
    static var stub3: User = .init(name: "이광혁", email: "dksdyd78@.com", descriptino: "짜증나", latitude: 36.979278264453125, longitude: 126.92241151386198)
    static var stub4: User = .init(name: "이찬희", email: "dksdyd78@naver.", descriptino: "짜증나", latitude: 36.979218564453125, longitude: 126.92241151386397)
    static var stub5: User = .init(name: "김민욱", email: "dksdyd78naver.com", descriptino: "짜증나", latitude: 36.979248564453125, longitude: 126.92241151486197)
    static var stub6: User = .init(name: "정인호", email: "dkdyd78@naver.com", descriptino:"짜증나", latitude: 36.979271564453125, longitude: 126.92241151386197)
}
