//
//  PathModel.swift
//  project
//
//  Created by 최안용 on 3/30/24.
//

import Foundation

final class PathModel: ObservableObject {
    @Published var paths: [PathType]
    
    init(paths: [PathType] = []) {
        self.paths = paths
    }
}
