//
//  NetworkManager.swift
//  project
//
//  Created by 최안용 on 3/19/24.
//

import Foundation

protocol NetworkManagerType {
    
}

import SwiftUI

struct APIResponse: Codable {
    // 이 구조체에는 API 응답에서 사용할 필요한 속성들을 추가할 수 있습니다.
}

class APIManager: ObservableObject {
    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE
    }
    
    let baseURL: String
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    func requestData<T: Codable>(endpoint: String, method: HTTPMethod = .GET, parameters: [String: Any]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let params = parameters {
            switch method {
            case .GET:
                let queryItems = params.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
                if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    urlComponents.queryItems = queryItems
                    request.url = urlComponents.url
                }
            default:
                request.httpBody = try? JSONSerialization.data(withJSONObject: params)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}


final class StubNetworkManager: NetworkManagerType {
    
}
