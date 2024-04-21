////
////  NetworkManager.swift
////  project
////
////  Created by 최안용 on 3/19/24.
////
//
//import Foundation
//import Combine
//
//enum NetworkError: Error {
//    case urlError
//    case tokenError
//    case responseError
//    case decodeError
//    case encodeError
//    case urlSessionError
//    case serverError(statusCode: Int)
//    case unknownError
//}
//
//enum HTTPMethod: String {
//    case GET
//    case POST
//    case PATCH
//}
//
//protocol NetworkManagerType {
//    func request<T: Decodable>(url: String,
//                               method: HTTPMethod,
//                               parameters: [String: String]?,
//                               isHTTPHeader: Bool) -> AnyPublisher<T, NetworkError>
//    func refreshAccessToken() -> String?
//}
// 
//final class NetworkManager: NetworkManagerType {
//    private let keychainManager: KeychainManager
//    private let hostURL = "https://emgapp.shop"
//    private var accessToken: String?
//
//    init(tokenManager: KeychainManager) {
//        self.keychainManager = tokenManager
//    }
//    
//    func request<T: Decodable>(url: String, 
//                               method: HTTPMethod,
//                               parameters: [String: String]?,
//                               isHTTPHeader: Bool)
//    -> AnyPublisher<T, NetworkError> {
//        guard let url = createURL(withPath: url) else {
//            return Fail(error: NetworkError.urlError)
//                .eraseToAnyPublisher()
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = method.rawValue
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        if isHTTPHeader {
//            guard let accessToken = getToken() else {
//                return Fail(error: NetworkError.tokenError)
//                    .eraseToAnyPublisher()
//            }
//            self.accessToken = accessToken
//            
//            request.addValue("Bearer \(self.accessToken!)", forHTTPHeaderField: "Authorization")
//        }
//        
//        if let parameters = parameters {
//            do {
//                let uploadData = try JSONEncoder().encode(parameters)
//                request.httpBody = uploadData
//            } catch {
//                return Fail(error: NetworkError.encodeError)
//                    .eraseToAnyPublisher()
//            }
//        }
//        
//        return URLSession.shared.dataTaskPublisher(for: request)
//            .mapError { error in
//                return NetworkError.urlSessionError
//            }
//            .flatMap { data, response -> AnyPublisher<T, NetworkError> in
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    return Fail(error: NetworkError.responseError)
//                        .eraseToAnyPublisher()
//                }
//                guard (200...299).contains(httpResponse.statusCode) else {
//                    return Fail(error: NetworkError.serverError(statusCode: httpResponse.statusCode))
//                        .eraseToAnyPublisher()
//                }
//                do {
//                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
//                    return Just(decodedObject)
//                        .setFailureType(to: NetworkError.self)
//                        .eraseToAnyPublisher()
//                } catch {
//                    return Fail(error: NetworkError.decodeError)
//                        .eraseToAnyPublisher()
//                }
//            }
//            .eraseToAnyPublisher()
//    }
//    
//    func refreshAccessToken() -> String? {
//        // refreshToken을 가져옵니다.
//        let (status, refreshToken) = self.keychainManager.read(account: "refreshToken")
//        let accessToken = getToken()
//         if status != errSecSuccess {
//             return nil
//         }
//
//        // 새로운 accessToken을 요청하기 위한 URLRequest를 준비합니다.
//        guard let url = createURL(withPath: "/login/reissue") else {
//            return nil
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // refreshToken을 요청 바디에 추가합니다.
//        guard let requestAccessToken = accessToken,
//              let requestRefreshToken = refreshToken else {
//            return nil
//        }
//        
//        let requestBody: [String: String] = ["accessToken": requestAccessToken,
//                                             "refreshToken": requestRefreshToken]
//        do {
//            let requestData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
//            request.httpBody = requestData
//        } catch {
//            return nil
//        }
//        
//        do {
//            let (data, response) = URLSession.shared.data(for: request)
//            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//                print("Error refreshing access token: Invalid server response")
//                return nil
//            }
//            let decodedObject = try JSONDecoder().decode(ServerAuthResponse.self, from: data)
//            let accessStatus =  keychainManager.update(account:"accessToken",
//                                                            value:decodedObject.accessToken)
//            let refreshStatus =  keychainManager.update(account:"refreshToken",
//                                                             value:decodedObject.refreshToken)
//            let expiresStatus = keychainManager.update(account:"accessTokenExpiresIn",
//                                                             value: String(decodedObject.accessTokenExpiresIn))
//            if accessStatus == errSecSuccess &&
//                refreshStatus == errSecSuccess &&
//                expiresStatus == errSecSuccess {
//                return decodedObject.accessToken
//            } else {
//                return nil
//            }
//        } catch {
//            return nil
//        }
//    }
//}
//
//extension NetworkManager {
//    private func createURL(withPath path: String)  -> URL? {
//        let urlString: String = "\(hostURL)\(path)"
//        guard let url = URL(string: urlString) else { return nil }
//        return url
//    }
//}
//
//
//final class StubNetworkManager: NetworkManagerType {
//    func refreshAccessToken() -> String? {
//        return ""
//    }
//
//    func request<T>(url: String, method: HTTPMethod, parameters: [String : String]?, isHTTPHeader: Bool) async -> AnyPublisher<T, NetworkError> where T : Decodable {
//        Empty().eraseToAnyPublisher()
//    }
//}
//



//
//
////  Provider.swift
////  project
////
////  Created by 최안용 on 4/19/24.
////
//
//import Foundation
//
///*
// request 2가지 종류
// 1) Encodable한 Request모델을 통해서 Decodable한 Response를 받는 request
// 2) 단순히 URL을 request를 주어 Data를 얻는 request(ex -이미지 url을 넣고 이미지 Data 얻어오는 경우 사용)
// */
//
//protocol Provider {
//    // 특정 responsable이 존재하는 request
//    func request<R: Decodable, E: RequestResponsable> (with endpoint: E, completion: @escaping (Result<R,Error>) -> Void) where E.Response == R
//    
//    // data를 얻는 request
//    func request(_ url: URL, completion: @escaping (Result<Data, Error>) -> ())
//}
//
//class ProviderImpl: Provider {
//    
//    let session: URLSessionable
//    init(session: URLSessionable = URLSession.shared) {
//        self.session = session
//    }
//    
//    func request<R: Decodable, E: RequestResponsable>(with endpoint: E, completion: @escaping (Result<R, Error>) -> Void) where E.Response == R {
//        do {
//            let urlRequest = try endpoint.getUrlRequest()
//            
//            session.dataTask(with: urlRequest) { [weak self] data, response, error in
//                self?.checkError(with: data, response, error) { result in
//                    guard let `self` = self else { return }
//                    
//                    switch result {
//                    case .success(let data):
//                        completion(`self`.decode(data: data))
//                    case .failure(let error):
//                        completion(.failure(error))
//                    }
//                }
//            }.resume()
//        } catch {
//            completion(.failure(NetworkError.urlRequest(error)))
//        }
//    }
//    
//    func request(_ url: URL, completion: @escaping (Result<Data, Error>) -> ()) {
//        session.dataTask(with: url) { [weak self] data, response, error in
//            self?.checkError(with: data, response, error, completion: { result in
//                completion(result)
//            })
//        }.resume()
//    }
//    
//    private func checkError(with data: Data?, _ response: URLResponse?, _ error: Error?, completion: @escaping (Result<Data, Error>) -> ()) {
//        if let error = error {
//            completion(.failure(error))
//            return
//        }
//        
//        guard let response = response as? HTTPURLResponse else {
//            completion(.failure(NetworkError.unknownError))
//            return
//        }
//        
//        guard (200...299).contains(response.statusCode) else {
//            completion(.failure(NetworkError.invalidHttpStatusCode(response.statusCode)))
//            return
//        }
//        
//        guard let data = data else {
//            completion(.failure(NetworkError.emptyData))
//            return
//        }
//        
//        completion(.success(data))
//    }
//    
//    private func decode<T: Decodable>(data: Data) -> Result<T, Error> {
//        do {
//            let decoded = try JSONDecoder().decode(T.self, from: data)
//            return .success(decoded)
//        } catch {
//            return .failure(NetworkError.emptyData)
//        }
//    }
//    
//    private func retryRequest(for request: URLRequest) {
//        
//    }
//}
//
//
//extension Encodable {
//    func toDictionary() throws -> [String: Any]? {
//        let data = try JSONEncoder().encode(self)
//        let jsonData = try JSONSerialization.jsonObject(with: data)
//        return jsonData as? [String: Any]
//    }
//}
