//
//  UploadService.swift
//  project
//
//  Created by 최안용 on 5/17/24.
//

import Foundation
import Alamofire

protocol UploadServiceType {
    func uploadImage(data: Data) async throws -> URL?
}

enum ImageError: Error {
    case iamgeError
}

final class UploadService: UploadServiceType {
    
    func uploadImage(data: Data) async throws -> URL? {
        let url = URL(string: ApiClient.BASE_URL + "/s3/upload")!
        
        
        
        let response = await ApiClient.shared.session.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "file", fileName: "image.jpeg", mimeType: "image/jpeg")
        }, to: url, method: .post, interceptor: AuthInterceptor.shared)
            .serializingDecodable(ImageUploadResponse.self)
            .response
        
        switch response.result {
        case .success(let resopnse):
            if (400..<599).contains(response.response?.statusCode ?? 0) {
                throw ImageError.iamgeError
            }
            return try resopnse.path.asURL()
        case .failure(let error):
            throw error
        }
    }
}

final class StubUploadService: UploadServiceType {
    func uploadImage(data: Data) async throws -> URL? {
        return nil
    }
}
