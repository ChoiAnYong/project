//
//  ApiLogger.swift
//  project
//
//  Created by 최안용 on 5/21/24.
//

import Foundation
import Alamofire

final class ApiLogger: EventMonitor {
    let queue = DispatchQueue(label: "project_ApiLogger")
    
    func requestDidResume(_ request: Request) {
        print("🚀ApiLogger - Resuming: \(request)")
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        debugPrint("Finished: \(response)")
    }
}
