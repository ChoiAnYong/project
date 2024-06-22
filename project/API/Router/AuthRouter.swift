//
//  AuthRouter.swift
//  project
//
//  Created by 최안용 on 5/21/24.
//

import Foundation
import Alamofire

enum AuthRouter: URLRequestConvertible {
    case login(LoginRequest)
    case refresh
    
    var baseURL: URL {
        return URL(string: ApiClient.BASE_URL)!
    }
    
    var endPoint: String {
        switch self {
        case .login:
            return "/oauth/apple/login"
        case .refresh:
            return "/oauth/reissue"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login: return .post
        case .refresh: return .post
        }
    }
    
    var parameters: RequestParams {
        switch self {
        case let .login(request):
            return .body(request)
        case .refresh:
            guard let access = KeychainManager.shared.read(account: SaveToken.access.rawValue),
                  let refresh = KeychainManager.shared.read(account: SaveToken.refresh.rawValue) 
            else { 
                return .body(RefreshRequest(accessToken: "", refreshToken: ""))
            }
            let request = RefreshRequest(accessToken: access, refreshToken: refresh)
            return .body(request)
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

enum RequestParams {
    case body(_ parameter: Encodable?)
    case query(_ Parameters: Encodable?)
    case empty
}
