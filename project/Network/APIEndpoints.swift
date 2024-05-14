//
//  APIEndpoints.swift
//  project
//
//  Created by 최안용 on 4/19/24.
//

import Foundation

struct APIEndpoints {
    static let baseURL = "https://emgapp.shop"
    // MARK: - 인증 관련
    
    // 앱 서버에 로그인 요청
    static func authenticateUser(with token: AppleLoginDTO) -> EndPoint<ServerAuthResponse> {
        return EndPoint(baseURL: baseURL,
                        path: "/login/apple",
                        method: .post,
                        bodyParameters: token,
                        needsToken: false,
                        headers: ["Content-Type":"application/json"],
                        sampleData: NetworkResponseMock.auth
                        )
    }
    
    // accessToken 갱신
    static func refreshAccessToken(with refresh: Refresh) -> EndPoint<ServerAuthResponse> {
        return EndPoint(baseURL: baseURL,
                        path: "/login/reissue",
                        method: .post,
                        bodyParameters: refresh,
                        needsToken: false,
                        headers: ["Content-Type":"application/json"]
                        )
    }
    
    // MARK: - 유저 정보 관련
    static func getUser() -> EndPoint<UserDTO> {
        return EndPoint(baseURL: baseURL,
                        path: "/member/home",
                        method: .get,
                        headers: ["Content-Type":"application/json"]
                        )
    }
    
    static func updateInfo<T: Encodable>(with info: T, path: String) -> EndPoint<String> {
        return EndPoint(baseURL: baseURL,
                        path: path,
                        method: .post,
                        bodyParameters: info,
                        headers: ["Content-Type":"application/json"]
                        )
    }
    
    static func getImages(with url: String) -> EndPoint<Data> {
        return EndPoint(baseURL: url)
    }
    
}
