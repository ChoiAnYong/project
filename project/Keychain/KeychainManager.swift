//
//  KeychainManager.swift
//  project
//
//  Created by 최안용 on 3/28/24.
//

import Foundation
import Security

enum SaveToken: String {
    case access = "accessToken"
    case refresh = "refreshToken"
}

final class KeychainManager {
    static let shared = KeychainManager()
    private let serviceUrl = "https://emgapp.shop/login/apple"
    
    func creat(account: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }
        
        let keyChainQuery: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceUrl,
            kSecAttrAccount: account,
            kSecValueData: data
        ] as CFDictionary
        
        SecItemDelete(keyChainQuery)

        if SecItemAdd(keyChainQuery, nil) == errSecSuccess {
            return true
        } else { return false }
    }
    
    func read(account: String) -> String? {
        let keyChainQuery: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceUrl,
            kSecAttrAccount: account,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        _ = SecItemCopyMatching(keyChainQuery, &dataTypeRef)
        
        guard let data = dataTypeRef as? Data else {
            return nil
        }
        
        let value = String(decoding: data, as: UTF8.self)
        return value
    }
    
    func update(account: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }
        
        let keyChainQuery: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceUrl,
            kSecAttrAccount: account
        ] as CFDictionary
        
        if SecItemUpdate(keyChainQuery, [kSecValueData: data] as CFDictionary) == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    func delete(account: String) -> Bool {
        let keyChainQuery: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceUrl,
            kSecAttrAccount: account
        ] as CFDictionary
        
        if SecItemDelete(keyChainQuery) == errSecSuccess {
            return true
        } else {
            return false
        }
    }
}
