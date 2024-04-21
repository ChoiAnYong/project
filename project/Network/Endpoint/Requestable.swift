//
//  Requestable.swift
//  project
//
//  Created by 최안용 on 4/19/24.
//

import Foundation

protocol Requestable {
    var baseURL: String { get }
    var path: String { get }
    var method: HttpMethod { get }
    var queryParameters: Encodable? { get }
    var bodyParameters: Encodable? { get }
    var headers: [String: String]? { get }
    var sampleData: Data? { get }
}

extension Requestable {
    // URLRequest를 생성하는 메서드
    // throws: URL 또는 매개변수에 문제가 있을 경우 NetworkError를 throw
    func getUrlRequest() throws -> URLRequest {
        let url = try url()
        var urlRequest = URLRequest(url: url)
        
        // bodyParameters를 JSON 데이터로 변화하여  httpBody에 설정
        if let bodyParameters = try bodyParameters?.toDictionary() {
            if !bodyParameters.isEmpty {
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters)
            }
        }
        
        // httpMethod 설정
        urlRequest.httpMethod = method.rawValue
        
        //header 설정
        headers?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        return urlRequest
    }
    
    // URL을 생성하는 메서드
    // throws: URL을 생성할 수 없는 경우 NetworkError를 throw
    func url() throws -> URL {
        // baseURL + path
        let fullPath = "\(baseURL)\(path)"
        guard var urlComponents = URLComponents(string: fullPath) else { throw NetworkError.components }
        
        // (baseURL + path) + queryParameters
        var urlQueryItems = [URLQueryItem]()
        if let queryParameters = try queryParameters?.toDictionary() {
            queryParameters.forEach {
                urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
            }
        }
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        
        guard let url = urlComponents.url else { throw NetworkError.components }
        return url
    }
}
