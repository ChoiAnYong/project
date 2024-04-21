//
//  MockURLSessionDataTask.swift
//  projectTests
//
//  Created by 최안용 on 4/21/24.
//

import Foundation

class MockURLSessionDataTask: URLSessionDataTask {
    var resumeDidCall: (() -> ())?
    
    override func resume() {
        resumeDidCall?()
    }
}
