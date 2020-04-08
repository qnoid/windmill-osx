//
//  Keychain.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 06/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

struct Keychain
{
    struct Account
    {
        let service : String
        let name : String
    }
    

    var keychain:SecKeychain?
    
    static let `default`: Keychain = {
        return Keychain()
    }()
    
    @discardableResult func add(_ account:Keychain.Account, value:String) -> OSStatus
    {
        guard let data = value.data(using: .utf8) else {
            return OSStatus(errSecDecode)
        }

        func attributes() -> [AnyHashable: Any] {
            #if DEBUG
            return [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: account.service,
                kSecAttrAccount: account.name,
                kSecValueData: data
                ]
            #else
            return [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: account.service,
                kSecAttrAccount: account.name,
                kSecValueData: data,
                kSecAttrIsInvisible: true
            ]
            #endif
        }
                
        return SecItemAdd(attributes() as CFDictionary, nil)
    }

    @discardableResult func update(_ account:Keychain.Account, value:String) -> OSStatus
    {
        guard let data = value.data(using: .utf8) else {
            return OSStatus(errSecDecode)
        }

        let query: [AnyHashable: Any] = [
            kSecAttrAccount: account.name,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: account.service
        ]
        
        let attributes: [AnyHashable: Any] = [kSecValueData: data]
        
        return SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    }

    func find(_ account:Keychain.Account) -> (status:OSStatus, value:String?) {

        var password: AnyObject? = nil
        
        let query: [AnyHashable: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: account.service,
            kSecAttrAccount: account.name,
            kSecReturnData: true
        ]

        let status = SecItemCopyMatching(query as CFDictionary, &password)
        
        guard let data = password as? Data else {
            return (OSStatus(errSecDecode), nil)
        }
        
        if status == OSStatus(errSecSuccess) {
        return (status, String(data: data, encoding: .utf8))
        }
        return (status, nil)
    }

    @discardableResult func delete(_ account:Keychain.Account) -> OSStatus
    {
        let query: [AnyHashable: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: account.service,
            kSecAttrAccount: account.name,
        ]
        
        return SecItemDelete(query as CFDictionary)
    }

}
