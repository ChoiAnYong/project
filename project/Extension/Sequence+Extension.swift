//
//  Sequence+Extension.swift
//  project
//
//  Created by 최안용 on 5/27/24.
//

import Foundation

extension Sequence {
    func asyncForEach(_ operation: (Element) async throws -> Void) async throws {
        for element in self {
            try await operation(element)
        }
    }
}
