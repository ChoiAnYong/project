//
//  BaseInterceptor.swift
//  project
//
//  Created by 최안용 on 5/21/24.
//

import Foundation
import Alamofire

class BaseInterceptor: RequestInterceptor {
    
    static let shared = BaseInterceptor()
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        var request = urlRequest
        
        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        completion(.success(request))
    }
}
