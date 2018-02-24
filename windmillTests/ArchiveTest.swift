//
//  ArchiveTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 18/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class ArchiveTest: XCTestCase {

    let dateFormatter = ISO8601DateFormatter()
    
    func testGivenInfoAtURLAssertInfo() {
        let url = Bundle(for: ArchiveTest.self).url(forResource: "Info", withExtension: "plist")!
        
        let info = Archive.Info(metadata: MetadataPlistEncoded(url: url))
        
        XCTAssertEqual(info.name, "windmill")
        XCTAssertEqual(info.bundleShortVersion, "1.0")
        XCTAssertEqual(info.bundleVersion, "1")
        XCTAssertEqual(info.creationDate, dateFormatter.date(from: "2017-08-18T16:24:30Z"))
        XCTAssertEqual(info.signingIdentity, "iPhone Developer: Markos Charatzas (YHA6TR5UG9)")
    }
}
