//
//  SHA256Test.swift
//  windmillTests
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

import XCTest

@testable import Windmill

class SHA256Test: XCTestCase {

    func testGivenBase64EncodedStringAssertHash() {
        let base64EncodedString = "4jTEe/bDZpbdbYUrmaqiuiZVVyg="
        let function = SHA256()
        
        let actual = try! function.hash(base64EncodedString: base64EncodedString)!
        
        XCTAssertEqual(actual, "T1DeVN+SdDCwwRseNSH4XdVu612ce+ETodKjapeB750=")
    }
    
    func testFoo() {
        let exportURL = Bundle(for: SHA256Test.self).url(forResource: "test", withExtension: "ipa")!
        let function = SHA256()
        
        let data = try! Data(contentsOf: exportURL)
        let actual = function.hash(data: data)
        
        let tokenString = actual.map { String(format: "%02x", $0) }.joined()
        
        XCTAssertEqual(tokenString, "8f61111eac91cfec06a6f415edd821f24b16fd838e93cc8ac9d9d692467b1633")
    }
}
