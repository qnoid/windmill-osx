//
//  StringTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 19/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class StringTest: XCTestCase {

    func testExampleEmpty() {
        let url = Bundle(for: StringTest.self).url(forResource: "Empty", withExtension: "txt")!

        let string = try! String(contentsOf: url)
        let lineNumber = string.count(length: 0)
        
        XCTAssertEqual(1, lineNumber)
    }
    
    func testExample() {
        let url = Bundle(for: StringTest.self).url(forResource: "25Lines", withExtension: "txt")!
        
        let string = try! String(contentsOf: url)
        let lineNumber = string.count(length: 0)

        XCTAssertEqual(1, lineNumber)
    }
    
    func testExample2() {
        let url = Bundle(for: StringTest.self).url(forResource: "25Lines", withExtension: "txt")!
        
        let string = try! String(contentsOf: url)
        let lineNumber = string.count(length: 145)
        
        XCTAssertEqual(9, lineNumber)
    }
    
    func testExample3() {
        
        let url = Bundle(for: StringTest.self).url(forResource: "25Lines", withExtension: "txt")!
        
        let string = try! String(contentsOf: url)
        let lineNumber = string.count(length: 506)
        
        XCTAssertEqual(25, lineNumber)
    }
    
    func testExample4() {
        let url = Bundle(for: StringTest.self).url(forResource: "25Lines", withExtension: "txt")!
        
        let string = try! String(contentsOf: url)
        let lineNumber = string.count(length: 507)
        
        XCTAssertEqual(25, lineNumber)
    }
}
