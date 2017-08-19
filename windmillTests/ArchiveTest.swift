//
//  ArchiveTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 18/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import XCTest

@testable import windmill

class ArchiveTest: XCTestCase {

    let dateFormatter = ISO8601DateFormatter()
    
    func testGivenInfoAtURLAssertInfo() {
        let url = Bundle(for: ArchiveTest.self).url(forResource: "Info", withExtension: "plist")!
        
        let info = try! Archive.Info.parse(url: url)!
        
        XCTAssertEqual(info.name, "windmill")
        XCTAssertEqual(info.bundleShortVersion, "1.0")
        XCTAssertEqual(info.bundleVersion, "1")
        XCTAssertEqual(info.creationDate, dateFormatter.date(from: "2017-08-18T16:24:30Z"))
    }
}
