//
//  SubscriberStatus.swift
//  windmill
//
//  Created by Markos Charatzas on 19/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation

/**
 The available stages in which a subscription status will progress, starting from the top
 
 .none       // No subscription exists yet on this device.
 .valid      // A subscription does exist and is the result of processed a valid receipt.
 .expired    // The subscription has expired. Using the associated account will result in a SubscriptionError.unauthorised(.expired)
 .active     // The subscription is currently active. The associated account can be used to access any of the services.
 */
enum SubscriptionStatus {
    
    static func make(account: String?, authorizationToken: String?) -> SubscriptionStatus? {
        
        guard let account = account else {
            return nil
        }
        
        guard let authorizationToken = authorizationToken, let jwt = try? JWT.jws(jwt: authorizationToken), let claims = try? Claims<SubscriptionAuthorizationToken>.accessToken(jwt: jwt), !claims.hasExpired() else {
            return nil
        }
        
        return SubscriptionStatus(account: Account(identifier: account), authorizationToken: SubscriptionAuthorizationToken(value: authorizationToken))
    }
    
    static func make(account: String?, claim: String?) -> SubscriptionStatus? {
        
        guard let account = account else {
            return nil
        }
        
        guard let claim = claim else {
            return nil
        }
        
        return SubscriptionStatus(account: Account(identifier: account), claim: SubscriptionClaim(value: claim))
    }
    
    static func make(claim: String?) -> SubscriptionStatus? {
        
        guard let claim = claim else {
            return nil
        }
        
        return SubscriptionStatus(claim: SubscriptionClaim(value: claim))
    }
    
    static var `default`: SubscriptionStatus {
        let claim = try? Keychain.default.read(key: .subscriptionClaim)
        let account = try? Keychain.default.read(key: .account)
        let authorizationToken = try? Keychain.default.read(key: .subscriptionAuthorizationToken)
        
        return make(account: account, authorizationToken: authorizationToken) ??
            make(account: account, claim: claim) ??
            make(claim: claim) ??
            .none
    }
    
    case active(account: Account, authorizationToken: SubscriptionAuthorizationToken)
    case expired(account: Account, claim: SubscriptionClaim)
    case valid(claim: SubscriptionClaim)
    case none
    
    init(claim: SubscriptionClaim){
        self = .valid(claim: claim)
    }
    
    init(account: Account, claim: SubscriptionClaim){
        self = .expired(account: account, claim: claim)
    }
    
    init?(account: Account, authorizationToken: SubscriptionAuthorizationToken){
        self = .active(account: account, authorizationToken: authorizationToken)
    }
    
    public var isActive: Bool {
        switch self {
        case .active:
            return true
        default:
            return false
        }
    }
}
