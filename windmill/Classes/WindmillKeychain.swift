//
//  WindmillKeychain.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 07/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

typealias KeychainFindUser = () throws -> String

extension Keychain.Account {
    static func make(service: String = "io.windmill.windmill", key: Keychain.Key) -> Keychain.Account {
        return Keychain.Account(service: service, name: key.stringValue)
    }
}

extension Keychain
{
    public enum Error: Swift.Error
    {
        case instance(OSStatus)
    }
    
    public enum Key: String, CodingKey {
        case account = "account_identifier"
        case subscriptionClaim = "subscription_claim"
        case subscriptionAuthorizationToken = "subscription_authorization_token"
    }
    
    public func read(key: Keychain.Key) throws -> String {

        let result = self.find(Keychain.Account.make(key: key))
        
        guard let value = result.value else {
            throw Keychain.Error.instance(result.status)
        }
        
        return value
    }
    
    @discardableResult func write(value: String, key: Keychain.Key) -> Bool
    {
        guard case .none = try? self.read(key: key) else {
            return self.update(Keychain.Account.make(key: key), value:value) == errSecSuccess
        }
        
        return self.add(Keychain.Account.make(key: key), value:value) == errSecSuccess
    }
}
