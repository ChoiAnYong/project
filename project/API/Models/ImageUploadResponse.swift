//
//  ImageUploadResponse.swift
//  project
//
//  Created by 최안용 on 5/23/24.
//

import Foundation

struct ImageUploadResponse: Decodable {
    let name, format, path: String
    let bytes: Int
    let createdAt: String
}
