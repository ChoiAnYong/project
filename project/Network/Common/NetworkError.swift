//
//  NetworkError.swift
//  project
//
//  Created by 최안용 on 4/19/24.
//

import Foundation

enum NetworkError: LocalizedError {
    case unknownError
    case invalidHttpStatusCode(Int)
    case components
    case urlRequest(Error)
    case parsing(Error)
    case emptyData
    case decodeError
    case tokenError
    
    var errorDescription: String? {
        switch self {
        case .unknownError: return "알수 없는 에러입니다."
        case .invalidHttpStatusCode: return "status코드가 200~299가 아닙니다."
        case .components: return "components를 생성 에러가 발생했습니다."
        case .urlRequest: return "URL request 관련 에러가 발생했습니다."
        case .parsing: return "데이터 parsing 중에 에러가 발생했습니다."
        case .emptyData: return "data가 비어있습니다."
        case .decodeError: return "decode 에러가 발생했습니다."
        case .tokenError: return "토큰를 가져오는 중에 에러가 발생했습니다."
        }
    }
}