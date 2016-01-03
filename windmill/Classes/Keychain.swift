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
        let status = SecKeychainAddGenericPassword(self.keychain,
            UInt32(account.serviceName.utf8.count), account.serviceName,
            UInt32(account.name.utf8.count), account.name,
            UInt32(password.utf8.count), password,
            nil)
        
        return status;
    }
    
    func findGenericPassword(account:KeychainAccount) -> (status:OSStatus, password:String?) {

        var passwordLength: UInt32 = 0
        var passwordPtr: UnsafeMutablePointer<Void> = nil
        
        let status = SecKeychainFindGenericPassword(self.keychain,
            UInt32(account.serviceName.utf8.count),
            account.serviceName,
            UInt32(account.name.utf8.count),
            account.name,
            &passwordLength,
            &passwordPtr,
            nil)
        
        if status == OSStatus(errSecSuccess) {
        let password = NSString(bytes: passwordPtr, length: Int(passwordLength), encoding: NSUTF8StringEncoding)
        return (status, password as? String)
        }
        return (status, nil)
    }

}