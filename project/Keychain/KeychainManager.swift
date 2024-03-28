//
//  KeychainManager.swift
//  project
//
//  Created by 최안용 on 3/28/24.
//

import Foundation
import Security

final class KeychainManager {
    
    private func creat(token: String, forAccount account: String) -> Bool {
        let keychainItem = [
            kSecClass: kSecClassGenericPassword
        ]
    }
}
