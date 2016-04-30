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
    var keychain:SecKeychainRef?
    
    public class func defaultKeychain() -> Keychain {
        return Keychain()
    }
    
    func addGenericPassword(account:KeychainAccount, password:String) -> OSStatus
    {
        
        let attributes: [NSObject: AnyObject] = [
            kSecClass: kSecClassGenericPassword as String,
            kSecAttrService: account.serviceName,
            kSecAttrAccount: account.name,
            kSecValueData: password.dataUsingEncoding(NSUTF8StringEncoding)!
        ]
                
        return SecItemAdd(attributes, nil);
    }
    
    func findGenericPassword(account:KeychainAccount) -> (status:OSStatus, password:String?) {

        var password: AnyObject? = nil
        
        let attributes: [NSObject: AnyObject] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: account.serviceName,
            kSecAttrAccount: account.name,
            kSecReturnData: true
        ]

        let status = SecItemCopyMatching(attributes, &password)
        
        if status == OSStatus(errSecSuccess) {
        return (status, String(data: password as! NSData, encoding: NSUTF8StringEncoding))
        }
        return (status, nil)
    }

}