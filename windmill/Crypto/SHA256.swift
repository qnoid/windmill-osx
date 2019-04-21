//
//  SHA1.swift
//  windmill
//
//  Created by Markos Charatzas on 19/04/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    
    func base64EncodedString() -> String? {
        return self.data(using: .utf8)?.base64EncodedString()
    }    
}

struct SHA256: CryptographicHashFunction {
    
    /**
     - parameter privateBase64String: the value encoded in base64
     - returns: hash of the given value in base64 or nil if the given value is not a base64 encoded string
     */
    func hash(base64EncodedString value: String) throws -> String? {
        guard let data = Foundation.Data(base64Encoded: value, options: []) else {
            return nil
        }
        
        return self.hash(data: data).base64EncodedString()
    }
    
    func hash(data: Data) -> Data {
        let hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), UnsafeMutablePointer<UInt8>(mutating: hash))
        }
        return Data(hash)
    }    
}
