//
//  KeychainManager.swift
//  project
//
//  Created by 최안용 on 3/28/24.
//

import Foundation
import Security

final class KeychainManager {
    static let serviceUrl = "https://emgapp.shop/login/apple"
    
    func creat(_ service: String, account: String, value: String) async -> OSStatus {
        guard let data = value.data(using: .utf8) else {
            return errSecBadReq
        }
        
        let keyChainQuery: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data
        ] as CFDictionary
        
        
        SecItemDelete(keyChainQuery)
        
        return SecItemAdd(keyChainQuery, nil)
    }
    
    func read(_ service: String, account: String) async -> (status: OSStatus, value: String?) {
        let keyChainQuery: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(keyChainQuery, &dataTypeRef)
        
        guard let data = dataTypeRef as? Data else {
            return (status, nil)
        }
        
        let value = String(decoding: data, as: UTF8.self)
        return (status, value)
    }
    
    func update(service: String, account: String, value: String) async -> OSStatus {
        guard let data = value.data(using: .utf8) else {
            return errSecBadReq
        }
        
        let keyChainQuery: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        
        return SecItemUpdate(keyChainQuery, [kSecValueData: data] as CFDictionary)
    }
    
    func delete(_ service: String, account: String) async -> OSStatus {
        let keyChainQuery: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        
        return SecItemDelete(keyChainQuery)
    }
}
