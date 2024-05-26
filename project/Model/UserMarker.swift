//
//  UserMarker.swift
//  project
//
//  Created by 최안용 on 5/7/24.
//

import Foundation

struct UserMarker: Hashable {
    var id: Int
    var lat: Double
    var lng: Double
    let imgUrl : String?
    let name : String
    var address: String?
    var distance: Double?
    var myMarker: Bool?
}

extension UserMarker {
    static var stubMarker1: UserMarker = .init(id: 1, lat: 36.9791, lng: 126.9222, imgUrl: "", name: "이찬희", myMarker: true)
    static var stubMarker2: UserMarker = .init(id: 1, lat: 36.7745, lng: 126.9338, imgUrl: "https://i.ibb.co/py7bBk0/2.png", name: "이준석")
}


