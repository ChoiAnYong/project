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

extension User {
    static var stubUser: User {
        .init(name: "최안용", profileUrl: "https://firebasestorage.googleapis.com/v0/b/lmessenger-d0f09.appspot.com/o/KakaoTalk_Photo_2024-05-14-20-37-15.jpeg?alt=media&token=37f6c24d-a36d-42e9-bd8c-fe3a29afb43d",email: "dksdyd78@naver.com",
              latitude: 36.7745, longitude: 126.9338)
    }
}
