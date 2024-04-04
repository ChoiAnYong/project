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
    case tokenError
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

enum HTTPMethod: String {
    case GET
    case POST
}

protocol NetworkManagerType {
    func request<T: Decodable>(url: String,
                               method: HTTPMethod,
                               parameters: [String: String]?,
                               isHTTPHeader: Bool)
    async -> AnyPublisher<T, NetworkError>
}

final class NetworkManager: NetworkManagerType {
    private let tokenManager: KeychainManager
    private let hostURL = "https://emgapp.shop"
    
    init(tokenManager: KeychainManager) {
        self.tokenManager = tokenManager
    }
    
    private func createURL(withPath path: String)  -> URL? {
        let urlString: String = "\(hostURL)\(path)"
        guard let url = URL(string: urlString) else { return nil }
        return url
    }
    
    private func getToken() async -> String? {
        let (status, value) = await self.tokenManager.read(KeychainManager.serviceUrl, account: "accessToken")
        if status == errSecSuccess {
            return value
        } else {
            return nil
        }
    }
    
    func request<T: Decodable>(url: String, 
                               method: HTTPMethod,
                               parameters: [String: String]?,
                               isHTTPHeader: Bool)
    async -> AnyPublisher<T, NetworkError> {
        guard let url = createURL(withPath: url) else {
            return Fail(error: NetworkError.urlError)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if isHTTPHeader {
            guard let token = await getToken() else {
                return Fail(error: NetworkError.tokenError)
                    .eraseToAnyPublisher()
            }
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let parameters = parameters {
            do {
                let uploadData = try JSONEncoder().encode(parameters)
                request.httpBody = uploadData
            } catch {
                return Fail(error: NetworkError.encodeError)
                    .eraseToAnyPublisher()
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { error in
                return NetworkError.mapURLError(error)
            }
            .flatMap { data, response -> AnyPublisher<T, NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: NetworkError.responseError)
                        .eraseToAnyPublisher()
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: NetworkError.serverError(statusCode: httpResponse.statusCode))
                        .eraseToAnyPublisher()
                }
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
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
    func request<T>(url: String, method: HTTPMethod, parameters: [String : String]?, isHTTPHeader: Bool) async -> AnyPublisher<T, NetworkError> where T : Decodable {
        Empty().eraseToAnyPublisher()
    }
}
