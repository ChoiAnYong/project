//
//  ApiClient.swift
//  project
//
//  Created by 최안용 on 5/21/24.
//

import Foundation
import Alamofire

final class ApiClient {
    static let shared = ApiClient()
    
    static let BASE_URL = "https://emgapp.shop"
    
    let monitors = [ApiLogger()] as [EventMonitor]
    
    var session: Session
    
    init() {
        print("ApiClient - init() called")
        session = Session(eventMonitors: monitors)
    }
}
