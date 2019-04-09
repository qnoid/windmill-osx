//
//  JWT.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

public enum JWTError: Error {
    case invalidClaim(reason: String)
}

extension JWTError : CustomNSError, LocalizedError {
    
    public static var errorDomain: String {
        return "io.windmill.windmill"
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidClaim(let reason):
            return reason
        }
    }
}


public struct JWT {
    
    public static func jws(jwt: String?) throws -> JWT {
        
        guard let jwt = jwt else {
            throw JWTError.invalidClaim(reason: "Claim is invalid.")
        }
        
        let segments = jwt.split(separator: ".");
        
        guard segments.count == 3 else {
            throw JWTError.invalidClaim(reason: "JWT is not of unsupported type.")
        }
        
        let encodedHeader = segments[0]
        let encodedPayload = segments[1]
        let encodedSignature = segments[2]
        
        return JWT(header: String(encodedHeader), payload: String(encodedPayload), signature: String(encodedSignature))
    }
    
    let header: String
    let payload: String
    let signature: String
    
}
