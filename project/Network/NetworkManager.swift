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
    case timeoutError
    case hostUnreachable
    case connectionLost
    case notConnected
    case responseError
    case decodeError
    case encodeError
    case serverError(statusCode: Int)
    case unknownError
    
    static func mapURLError(_ error: Error) -> NetworkError {
       guard let urlError = error as? URLError else {
           return NetworkError.unknownError
       }
       
       switch urlError.code {
       case .timedOut:
           return .timeoutError
       case .cannotFindHost, .cannotConnectToHost:
           return .hostUnreachable
       case .networkConnectionLost:
           return .connectionLost
       case .notConnectedToInternet:
           return .notConnected
       default:
           return .unknownError
       }
   }
}

protocol NetworkManagerType {
    func requestGET<T: Codable>(url: String, decodeType: T) -> AnyPublisher<T,NetworkError>
    func requestPOSTModel<T: Codable, U: Codable>(url: String, parameters: T, ishttpHeader: Bool) -> AnyPublisher<U, NetworkError>
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

    func requestPOSTModel<T: Codable, U: Codable>(url: String, parameters: T, ishttpHeader: Bool) -> AnyPublisher<U, NetworkError> {
        guard let url = createURL(withPath: url) else {
            return Fail(error: NetworkError.urlError)
                .eraseToAnyPublisher()
        }
                    
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if ishttpHeader {
            let tk = KeychainManager()
            guard let accessToken = tk.read("\(hostURL)/apple", account: "accessToken") else {
                return Fail(error: NetworkError.urlError)
                    .eraseToAnyPublisher()
            }
            
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let uploadData = try JSONEncoder().encode(parameters)
            request.httpBody = uploadData
        } catch {
            return Fail(error: NetworkError.encodeError)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { error in
                return NetworkError.mapURLError(error)
            }
            .flatMap { data, response -> AnyPublisher<U,NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: NetworkError.responseError)
                        .eraseToAnyPublisher()
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: NetworkError.serverError(statusCode: httpResponse.statusCode))
                        .eraseToAnyPublisher()
                }
                do {
                    let decodedObject = try JSONDecoder().decode(U.self, from: data)
                    return Just(decodedObject)
                        .setFailureType(to: NetworkError.self)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: NetworkError.decodeError)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

final class StubNetworkManager: NetworkManagerType {
    func requestGET<T>(url: String, decodeType: T) -> AnyPublisher<T, NetworkError> where T : Decodable, T : Encodable {
        Empty().eraseToAnyPublisher()
    }
    
    func requestPOSTModel<T, U>(url: String, parameters: T, ishttpHeader: Bool) -> AnyPublisher<U, NetworkError> where T : Decodable, T : Encodable, U : Decodable, U : Encodable {
        Empty().eraseToAnyPublisher()
    }
    
    
}
