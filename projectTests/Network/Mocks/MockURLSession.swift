//
//  MockURLSession.swift
//  projectTests
//
//  Created by 최안용 on 4/21/24.
//

import Foundation
@testable import project

class MockURLSession: URLSessionable {
    var makeRequestFail = false
    init(makeRequestFail: Bool = false) {
        self.makeRequestFail = makeRequestFail
    }
    
    var sessionDataTask: MockURLSessionDataTask?
    
    func dataTask(with request: URLRequest, 
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let endPoint = APIEndpoints.authenticateUser(with: .init(idToken: "d", name: "최안용", deviceToken: "dkasl"))
        
        let successResponse = HTTPURLResponse(url: try! endPoint.url(),
                                              statusCode: 200,
                                              httpVersion: "2",
                                              headerFields: nil)
        
        let failureResponse = HTTPURLResponse(url: try! endPoint.url(),
                                              statusCode: 301,
                                              httpVersion: "2",
                                              headerFields: nil)
        
        let sessionDataTask = MockURLSessionDataTask()
        
        sessionDataTask.resumeDidCall = {
            if self.makeRequestFail {
                completionHandler(nil, failureResponse, nil)
            } else {
                completionHandler(endPoint.sampleData!, successResponse, nil)
            }
        }
        self.sessionDataTask = sessionDataTask
        return sessionDataTask
    }
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return sessionDataTask!
    }
}
