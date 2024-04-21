//
//  Provider.swift
//  project
//
//  Created by 최안용 on 4/19/24.
//

import Foundation

/*
 request 2가지 종류
 1) Encodable한 Request모델을 통해서 Decodable한 Response를 받는 request
 2) 단순히 URL을 request를 주어 Data를 얻는 request(ex -이미지 url을 넣고 이미지 Data 얻어오는 경우 사용)
 */

protocol Provider {
    // 특정 responsable이 존재하는 request
    func request<R: Decodable, E: RequestResponsable> (with endpoint: E, completion: @escaping (Result<R,Error>) -> Void) where E.Response == R
    
    // data를 얻는 request
    func request(_ url: URL, completion: @escaping (Result<Data, Error>) -> ())
}

class ProviderImpl: Provider {
    private var failUrlRequest: URLRequest?
    private let keychainManager: KeychainManager
    
    let session: URLSessionable
    init(session: URLSessionable = URLSession.shared, keychainManager: KeychainManager) {
        self.session = session
        self.keychainManager = keychainManager
    }
    
    func request<R: Decodable, E: RequestResponsable>(with endpoint: E, completion: @escaping (Result<R, Error>) -> Void) where E.Response == R {
        do {
            let urlRequest = try endpoint.getUrlRequest()
            failUrlRequest = urlRequest
            
            
            session.dataTask(with: urlRequest) { [weak self] data, response, error in
                self?.checkError(with: data, response, error) { result in
                    guard let `self` = self else { return }
                    
                    switch result {
                    case .success(let data):
                        completion(`self`.decode(data: data))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }.resume()
        } catch {
            completion(.failure(NetworkError.urlRequest(error)))
        }
    }
    
    func request(_ url: URL, completion: @escaping (Result<Data, Error>) -> ()) {
        session.dataTask(with: url) { [weak self] data, response, error in
            self?.checkError(with: data, response, error, completion: { result in
                completion(result)
            })
        }.resume()
    }
    
    private func checkError(with data: Data?, _ response: URLResponse?, _ error: Error?, completion: @escaping (Result<Data, Error>) -> ()) {
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let response = response as? HTTPURLResponse else {
            completion(.failure(NetworkError.unknownError))
            
            return
        }
        
        guard (200...299).contains(response.statusCode) else {
            if response.statusCode == 401 {
                refreshAccessToken { result in
                    switch result {
                    case let .success(response):
                        if var failUrlRequest = self.failUrlRequest {
                            failUrlRequest.setValue("Bearer \(response.accessToken)", forHTTPHeaderField: "Authorization")
                            self.session.dataTask(with: failUrlRequest) { data, _, error in
                                if let error = error {
                                    completion(.failure(error))
                                } else if let data = data {
                                    completion(.success(data))
                                } else {
                                    completion(.failure(NetworkError.emptyData))
                                }
                            }.resume()
                        } else {
                            completion(.failure(NetworkError.emptyData))
                        }
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            } else {
                completion(.failure(NetworkError.invalidHttpStatusCode(response.statusCode)))
            }
            return
        }
        
        guard let data = data else {
            completion(.failure(NetworkError.emptyData))
            return
        }
        
        completion(.success(data))
    }
    
    private func decode<T: Decodable>(data: Data) -> Result<T, Error> {
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(NetworkError.emptyData)
        }
    }
    
    private func refreshAccessToken(completion: @escaping (Result<ServerAuthResponse, Error>) -> Void) {
        guard let accessToken = keychainManager.read(account: "accessToken").value,
              let refreshToken = keychainManager.read(account: "refreshToken").value else {
            completion(.failure(NetworkError.tokenError))
            return
        }
        
        let refreshRequest = Refresh(accessToken: accessToken, refreshToken: refreshToken)
        let endpoint = APIEndpoints.refreshAccessToken(with: refreshRequest)
        
        request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(response):
                let accessStatus = self.keychainManager.update(account: "accessToken", 
                                                               value: response.accessToken)
                
                let refreshStatus = self.keychainManager.update(account: "refreshToken",
                                                               value: response.refreshToken)
                
                if accessStatus == errSecSuccess && refreshStatus == errSecSuccess {
                    completion(.success(response))
                } else {
                    completion(.failure(AuthenticationError.tokenError))
                }
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}


extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        return jsonData as? [String: Any]
    }
}
