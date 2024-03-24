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
    func requestPOSTModel(url: String, parameters: [String: Any]) -> AnyPublisher<String, NetworkError>
}

final class NetworkManager: NetworkManagerType {
    private let hostURL = "http://43.203.54.29:8080/api/apple"
    
    private func createURL(withPath path: String) throws -> URL {
        let urlString: String = "\(hostURL)\(path)"
        guard let url = URL(string: urlString) else { throw NetworkError.urlError }
        return url
    }
    
    private func fetchData(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.responseError }
        
        switch httpResponse.statusCode {
        case 200...299:
            return data
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    func requestGET<T: Decodable>(url: String, decodeType: T) -> AnyPublisher<T,NetworkError> {
        do {
            let url = try createURL(withPath: url)
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
    
    func requestPOSTModel(url: String, parameters: [String: Any]) -> AnyPublisher<String, NetworkError> {
        do {
            let uploadData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            let url = try createURL(withPath: url)
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
                        let decodedObject = try JSONDecoder().decode(String.self, from: data)
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
