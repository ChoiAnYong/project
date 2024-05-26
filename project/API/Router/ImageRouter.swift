//
//  ImageRouter.swift
//  project
//
//  Created by 최안용 on 5/23/24.
//

//import Foundation
//import Alamofire
//
//enum ImageRouter: URLRequestConvertible {
//    
//    case loadImage(url: URL)
//    case uploadImage(imageData: Data)
//    
//    var baseURL: URL {
//        return URL(string: ApiClient.BASE_URL)!
//    }
//    
//    var endPoint: String {
//        switch self {
//        case .uploadImage:
//            return "/s3/upload"
//        default: break
//        }
//    }
//    
//    var method: HTTPMethod {
//        switch self {
//        case .loadImage: return .post
//        default: break
//        }
//    }
//    
//    
//    
//    func asURLRequest() throws -> URLRequest {
//        <#code#>
//    }
//}
