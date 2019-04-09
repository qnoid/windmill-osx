//
//  Claims.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

public enum ClaimsType: String, Decodable {
    case subscription = "sub"
    case access_token = "at"
}

extension String {
    
    func wml_base64URLDecode() -> Data? {
        
        var string = self
        if string.count % 4 != 0 {
            let count = 4 - string.count % 4
            string.append(contentsOf: repeatElement("=", count: count))
        }
        
        return Data(base64Encoded: string)
    }
}

public class Claims<T>: Decodable {
    
    static func make<T>(jwt: JWT) throws -> Claims<T> {
        
        guard let decodedPayload = jwt.payload.wml_base64URLDecode() else {
            throw JWTError.invalidClaim(reason: "Incorrect format.")
        }
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let date = try decoder.singleValueContainer().decode(Double.self)
            
            return Date(timeIntervalSince1970: date)
        }
        
        guard let claims = try? decoder.decode(Claims.self, from: decodedPayload), let make = claims as? Claims<T> else {
            throw JWTError.invalidClaim(reason: "Claim is invalid.")
        }
        
        return make
    }
    
    static func subscription(jwt: JWT) throws -> Claims<SubscriptionClaim> {
        return try make(jwt: jwt)
    }
    
    static func accessToken(jwt: JWT) throws -> Claims<SubscriptionAuthorizationToken> {
        return try make(jwt: jwt)
    }
    
    var jti: String?
    var sub: String?
    var exp: Date?
    var typ: ClaimsType?
    var v: Int?
    
    public func hasExpired() -> Bool {
        
        guard let exp = self.exp else {
            return false
        }
        
        return exp < Date()
    }
}
