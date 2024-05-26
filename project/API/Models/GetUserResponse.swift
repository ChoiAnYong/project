//
//  GetUserRequest.swift
//  project
//
//  Created by 최안용 on 5/20/24.
//

import Foundation

struct GetUserResponse: Decodable {
    var name: String
    var profileUrl: String?
    var email: String
    var hasWatch: Bool?
    var location: LocationDTO?
    var connectionMemberDtoList: [OtherDTO]
}

struct LocationDTO: Codable {
    var latitude: Double
    var longitude: Double
}

struct OtherDTO: Codable {
    var name: String
    var email: String
    var profileUrl: String?
    var location: LocationDTO?
    var emgState: Bool
}

extension GetUserResponse {
    func toModel() -> (User,[ConnectedUser]) {
        let myUser = User(name: name,
                          profileUrl: profileUrl,
                          email: email,
                          hasWatch: hasWatch,
                          latitude: location?.latitude,
                          longitude: location?.longitude,
                          connectionMemberDtoList: connectionMemberDtoList)
        
        let connectionUsers = connectionMemberDtoList.map { otherObject in
            ConnectedUser(name: otherObject.name,
                          email: otherObject.email,
                          profileUrl: otherObject.profileUrl,
                          latitude: otherObject.location?.latitude,
                          longitude: otherObject.location?.longitude,
                          emgState: otherObject.emgState)
        }
        return (myUser, connectionUsers)
    }
}
