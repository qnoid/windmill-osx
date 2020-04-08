//
//  SHA1.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 19/04/2019.
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
