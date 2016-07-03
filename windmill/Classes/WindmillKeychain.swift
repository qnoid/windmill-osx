//
//  WindmillKeychain.swift
//  windmill
//
//  Created by Markos Charatzas on 07/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

typealias KeychainCreateUser = (String) -> OSStatus

typealias KeychainFindUser = () throws -> String

let KeychainWindmillAccount = KeychainAccount(serviceName: "io.windmill", name: "io.windmill.account")

enum KeychainError: ErrorType
{
    case Instance(OSStatus)
}

extension Keychain
{
    private var createWindmillUser : KeychainCreateUser
    {
        func createUser(user:String) -> OSStatus {
        return self.addGenericPassword(KeychainWindmillAccount, password:user)
        }
        
        return createUser;
    }
    
    var findWindmillUser : KeychainFindUser
    {
        func findUser() throws -> String
        {
            let account = self.findGenericPassword(KeychainWindmillAccount);
            
            guard let user = account.password else {
                throw KeychainError.Instance(account.status)
            }
            
        return user
        }

    return findUser;
    }
    
    /**
    Creates a new user under the KeychainAccountIOWindmillUsers if one doesn't already exist.
    
    As a result of calling this method, a subsequent call to #findWindmillUser is guaranteed to return a user.

    @param user the user to create
    @return true if created, false otherwise
    */
    func createUser(user:String) -> Bool
    {
        guard let _ = try? self.findWindmillUser() else {
            self.createWindmillUser(user)
            return true
        }
        
    return false
    }
}
