//
//  ImageDTO.swift
//  project
//
//  Created by 최안용 on 5/17/24.
//

import Foundation
struct MultipartFormData {
    let key: String
    let value: Data
    let filename: String?
    let mimeType: String
    
    init(key: String, value: Data, filename: String? = nil, mimeType: String = "application/octet-stream") {
        self.key = key
        self.value = value
        self.filename = filename
        self.mimeType = mimeType
    }
}
