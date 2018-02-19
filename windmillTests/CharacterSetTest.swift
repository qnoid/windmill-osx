//
//  CharacterSetTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 18/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import XCTest

@testable import windmill

class CharacterSetTest: XCTestCase {

    func testGivenRandomAlphaNumericAssertLength() {
        let random = CharacterSet.Windmill.random(characters: CharacterSet.alphanumerics, length: 32)
        
        XCTAssertEqual(32, random.count)
    }
}
