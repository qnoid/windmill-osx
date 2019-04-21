//
//  SHA256Test.swift
//  windmillTests
//
//  Created by Markos Charatzas on 19/04/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
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
