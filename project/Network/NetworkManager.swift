//
//  NetworkManager.swift
//  project
//
//  Created by 최안용 on 3/19/24.
//

import Foundation

enum NetworkError: Error {
    case urlError
    case responseError
    case decodeError
    case serverError(statusCode: Int)
    case unknownError
}

protocol NetworkManagerType {
    func requestGET<T: Decodable>(url: String) async throws -> T
    func requestPOSTWithURLSessionUploadTask(url: String, parameters: [String : Any]) async throws
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
    
    func requestGET<T: Decodable>(url: String) async throws -> T {
        let url = try createURL(withPath: url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let defaultSession = URLSession(configuration: .default)
        
        let (data, response) = try await defaultSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let httpResponse = response as? HTTPURLResponse {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            } else {
                throw NetworkError.responseError
            }
        }
        
        let decoder = JSONDecoder()
        
        do {
            let decodedObject = try decoder.decode(T.self, from: data)
            return decodedObject
        } catch {
            throw NetworkError.decodeError
        }
    }
    
    func requestPOSTWithURLSessionUploadTask(url: String, parameters: [String : Any]) async throws {
        let uploadData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let url = try createURL(withPath: url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let defaultSession = URLSession(configuration: .default)
        
        let uploadTask = defaultSession.uploadTask(with: request, from: uploadData) { data, response, error in
            // 업로드 완료 후 처리할 코드 작성
            if let error = error {
                // 오류 처리
                print("Error uploading data: \(error)")
                return
            }
            
            // 업로드가 성공적으로 완료됐을 때 수행할 코드 작성
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                print("HTTP Status Code: \(httpResponse.allHeaderFields)")
                // 서버 응답을 처리할 수 있습니다.
            }
            
            if let data = data {
                // 업로드한 데이터를 처리할 수 있습니다.
                print("Uploaded data: \(data)")
            }
        }
        
        // 업로드 작업 시작
        uploadTask.resume()
    }


    
}
