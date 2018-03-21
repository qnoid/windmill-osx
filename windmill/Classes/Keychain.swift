//
//  Keychain.swift
//  windmill
//
//  Created by Markos Charatzas on 06/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

struct KeychainAccount
{
    let serviceName : String
    let name : String
}

final public class Keychain
{
    var keychain:SecKeychain?
    
    public class func defaultKeychain() -> Keychain {
        return Keychain()
    }
    
    @discardableResult func addGenericPassword(_ account:KeychainAccount, password:String) -> OSStatus
    {
        
        let attributes: [AnyHashable: Any] = [
            kSecClass: kSecClassGenericPassword as String,
            kSecAttrService: account.serviceName,
            kSecAttrAccount: account.name,
            kSecValueData: password.data(using: String.Encoding.utf8)!
        ]
                
        return SecItemAdd(attributes as CFDictionary, nil)
    }
    
    func findGenericPassword(_ account:KeychainAccount) -> (status:OSStatus, password:String?) {

        var password: AnyObject? = nil
        
        let attributes: [AnyHashable: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: account.serviceName,
            kSecAttrAccount: account.name,
            kSecReturnData: true
        ]

        let status = SecItemCopyMatching(attributes as CFDictionary, &password)
        
        if status == OSStatus(errSecSuccess) {
        return (status, String(data: password as! Data, encoding: String.Encoding.utf8))
        }
        return (status, nil)
    }

}
