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
                        headers: ["Content-Type":"application/json"])
    }
    
    // 앱 서버에 로그인 상태 확인
//    static func checkAuthForServer()
    
    // MARK: - 유저 정보 관련
    static func getUser(token: String) -> EndPoint<UserDTO> {
        return EndPoint(baseURL: baseURL,
                        path: "/member/home",
                        method: .get,
                        headers: ["Content-Type":"application/json",
                                  "Authorization": "Bearer \(token)"]
                        )
    }
    
    
}
