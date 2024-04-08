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
    func refreshAccessToken() async -> String?
}

final class NetworkManager: NetworkManagerType {
    private let tokenManager: KeychainManager
    private let hostURL = "https://emgapp.shop"
    private var accessToken: String?

    init(tokenManager: KeychainManager) {
        self.tokenManager = tokenManager
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
            guard let accessToken = await getToken(),
                  let expires = await getExpires() else {
                return Fail(error: NetworkError.tokenError)
                    .eraseToAnyPublisher()
            }
            self.accessToken = accessToken
            
            // 만료 검사 및 갱신
            if isExpired(expirationTimestamp: expires) {
                guard let newAccessToken = await refreshAccessToken() else {
                    return Fail(error: NetworkError.tokenError)
                        .eraseToAnyPublisher()
                }
                self.accessToken = newAccessToken
            }
            
            request.addValue("Bearer \(self.accessToken!)", forHTTPHeaderField: "Authorization")
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

extension NetworkManager {
    private func createURL(withPath path: String)  -> URL? {
        let urlString: String = "\(hostURL)\(path)"
        guard let url = URL(string: urlString) else { return nil }
        return url
    }
    
    private func getToken() async -> String? {
        let (status, value) = await self.tokenManager.read(KeychainManager.serviceUrl,
                                                           account: "accessToken")
        if status == errSecSuccess {
            return value
        } else {
            return nil
        }
    }
    
    private func getExpires() async -> String? {
        let (status, value) = await self.tokenManager.read(KeychainManager.serviceUrl,
                                                           account: "accessTokenExpiresIn")
        if status == errSecSuccess {
            return value
        } else {
            return nil
        }
    }
    
    private func isExpired(expirationTimestamp: String) -> Bool {
        
        guard let expiration = Int64(expirationTimestamp) else {
            // 변환에 실패한 경우 유효하지 않은 것으로 처리합니다.
            return true
        }
        
        
        let expirationSeconds = TimeInterval(expiration) / 1000.0
        
        
        let expirationDate = Date(timeIntervalSince1970: expirationSeconds)
        
        
        let now = Date()
        
        // 유효 기간이 현재 시간보다 이전인지 확인합니다.
        return expirationDate.timeIntervalSince1970 < now.timeIntervalSince1970
    }

    func refreshAccessToken() async -> String? {
        // refreshToken을 가져옵니다.
        let (status, refreshToken) = await self.tokenManager.read(KeychainManager.serviceUrl,
                                                            account: "refreshToken")
        let accessToken = await getToken()
         if status != errSecSuccess {
             return nil
         }

        // 새로운 accessToken을 요청하기 위한 URLRequest를 준비합니다.
        guard let url = createURL(withPath: "/login/reissue") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // refreshToken을 요청 바디에 추가합니다.
        guard let requestAccessToken = accessToken,
              let requestRefreshToken = refreshToken else {
            return nil
        }
        
        let requestBody: [String: String] = ["accessToken": requestAccessToken, 
                                             "refreshToken": requestRefreshToken]
        do {
            let requestData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = requestData
        } catch {
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Error refreshing access token: Invalid server response")
                return nil
            }
            let decodedObject = try JSONDecoder().decode(ServerAuthResponse.self, from: data)
            let accessStatus = await tokenManager.update(KeychainManager.serviceUrl,
                                              account:"accessToken",
                                              value:decodedObject.accessToken)
            let refreshStatus = await tokenManager.update(KeychainManager.serviceUrl,
                                               account:"refreshToken",
                                               value:decodedObject.refreshToken)
            let expiresStatus = await tokenManager.update(KeychainManager.serviceUrl,
                                               account:"accessTokenExpiresIn",
                                               value: String(decodedObject.accessTokenExpiresIn))
            if accessStatus == errSecSuccess &&
                refreshStatus == errSecSuccess &&
                expiresStatus == errSecSuccess {
                return decodedObject.accessToken
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}


final class StubNetworkManager: NetworkManagerType {
    func refreshAccessToken() async -> String? {
        return ""
    }
    
    func request<T>(url: String, method: HTTPMethod, parameters: [String : String]?, isHTTPHeader: Bool) async -> AnyPublisher<T, NetworkError> where T : Decodable {
        Empty().eraseToAnyPublisher()
    }
}
