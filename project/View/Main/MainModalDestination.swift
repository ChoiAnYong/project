//
//  MainModalDestination.swift
//  project
//
//  Created by 최안용 on 5/13/24.
//

import Foundation

enum MainModalDestination: Hashable, Identifiable {
    case myProfile
    case userAlarm(String)
    
    var id: Int {
        hashValue
    }
}
