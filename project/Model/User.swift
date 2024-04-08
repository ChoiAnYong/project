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
    
}

extension User {
    static var stub1: User = .init(name: "최안용", email: "dksdyd78@naver.com", descriptino: "씨발")
    static var stub2: User = .init(name: "씨발", email: "@naver.com", descriptino: "짜증나")
    static var stub3: User = .init(name: "씨발", email: "dksdyd78@.com", descriptino: "짜증나")
    static var stub4: User = .init(name: "씨발", email: "dksdyd78@naver.", descriptino: "짜증나")
    static var stub5: User = .init(name: "씨발", email: "dksdyd78naver.com", descriptino: "짜증나")
    static var stub6: User = .init(name: "씨발", email: "dkdyd78@naver.com", descriptino: "짜증나")
}
