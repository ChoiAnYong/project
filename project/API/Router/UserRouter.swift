//
//  UserRouter.swift
//  project
//
//  Created by 최안용 on 5/21/24.
//

import Foundation
import Alamofire

enum UserRouter: URLRequestConvertible {
    
    
    case getUser//GetUserResponse
    case updateLocation(LocationDTO) //String
    
    var baseURL: URL {
        return URL(string: ApiClient.BASE_URL)!
    }
    
    var endPoint: String {
        switch self {
        case .getUser:
            return "/member/home"
        case .updateLocation:
            return "/member/gps"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getUser: return .get
        case .updateLocation: return .post
        }
    }
    
    var parameters: RequestParams {
        switch self {
        case .getUser:
            return .empty
        case .updateLocation(let locationDTO):
            return .body(locationDTO)
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(endPoint)
        var request = URLRequest(url: url)
        request.method = method
        
        switch parameters {
        case .body(let param):
            let params = try param?.toDictionary() ?? [:]
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        default:
            break
        }
        
        return request
    }
}
