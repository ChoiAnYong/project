//
//  NetworkManager.swift
//  project
//
//  Created by 최안용 on 3/19/24.
//

import Foundation
import Combine

enum NetworkError: Error {
    case urlError
    case responseError
    case decodeError
    case serverError(statusCode: Int)
    case unknownError
}

protocol NetworkManagerType {
    func requestGET<T: Codable>(url: String, decodeType: T) -> AnyPublisher<T,NetworkError>
    func requestPOSTModel<T: Codable, U: Codable>(url: String, parameters: T) -> AnyPublisher<U, NetworkError> 
}

final class NetworkManager: NetworkManagerType {
    private let hostURL = "https://emgapp.shop/login"
    
    private func createURL(withPath path: String)  -> URL? {
        let urlString: String = "\(hostURL)\(path)"
        guard let url = URL(string: urlString) else { return nil }
        return url
    }
    
    func requestGET<T: Decodable>(url: String, decodeType: T) -> AnyPublisher<T,NetworkError> {
        do {
            guard let url = createURL(withPath: url) else { throw NetworkError.urlError }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw NetworkError.responseError
                    }
                    guard (200...299).contains(httpResponse.statusCode) else {
                        throw NetworkError.serverError(statusCode: httpResponse.statusCode)
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { error in
                    if let networkError = error as? NetworkError {
                        return networkError
                    } else {
                        return NetworkError.unknownError
                    }
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: NetworkError.urlError).eraseToAnyPublisher()
        }
    }

    func requestPOSTModel<T: Codable, U: Codable>(url: String, parameters: T) -> AnyPublisher<U, NetworkError> {
        do {
            let uploadData = try JSONEncoder().encode(parameters)
            
            guard let url = createURL(withPath: url) else { throw NetworkError.urlError }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = uploadData
            
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw NetworkError.responseError
                    }
                    guard (200...299).contains(httpResponse.statusCode) else {
                        throw NetworkError.serverError(statusCode: httpResponse.statusCode)
                    }
                    do {
                        let decodedObject = try JSONDecoder().decode(U.self, from: data)
                        return decodedObject
                    } catch {
                        throw NetworkError.decodeError
                    }
                }
                .mapError { error in
                    // Swift의 type casting 문법을 사용하여 Error 타입을 NetworkError로 변환합니다.
                    if let networkError = error as? NetworkError {
                        return networkError
                    } else {
                        return NetworkError.unknownError
                    }
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: NetworkError.urlError).eraseToAnyPublisher()
        }
    }
}

final class StubNetworkManager: NetworkManagerType {
    func requestGET<T>(url: String, decodeType: T) -> AnyPublisher<T, NetworkError> where T : Decodable, T : Encodable {
        Empty().eraseToAnyPublisher()
    }
    
    func requestPOSTModel<T, U>(url: String, parameters: T) -> AnyPublisher<U, NetworkError> where T : Decodable, T : Encodable, U : Decodable, U : Encodable {
        Empty().eraseToAnyPublisher()
    }
    
    
}
