//
//  WindmillKeychain.swift
//  windmill
//
//  Created by Markos Charatzas on 07/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

typealias KeychainCreateUser = (String) -> OSStatus

typealias KeychainFindUser = () -> NSString?

let KeychainAccountIOWindmillUser = KeychainAccount(serviceName: "io.windmill", name: "io.windmill.user")

extension Keychain
{
    var createUser : KeychainCreateUser
    {
        func createUser(user:String) -> OSStatus {
        return self.addGenericPassword(KeychainAccountIOWindmillUser, password:user)
        }
        
        return createUser;
    }
    
    var findUser : KeychainFindUser
    {
        func findUser() -> NSString?
        {
            let account = self.findGenericPassword(KeychainAccountIOWindmillUser);
            
            if let user = account.password{
                return user;
            }
            
        return nil
        }

    return findUser;
    }
    
    /**
    Creates a new user under the KeychainAccountIOWindmillUsers if one doesn't already exist.

    @param user the user to create
    @return true if created, false otherwise
    */
    func createUser(user:String) -> Bool
    {
        if let user = self.findUser(){
            return false
        }
        
        self.createUser(user)
        
    return true
    }
}
