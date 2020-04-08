//
//  Claims.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 12/03/2019.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
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
