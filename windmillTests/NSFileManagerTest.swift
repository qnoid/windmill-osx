//
//  NSFileManagerTest.swift
//  windmill
//
//  Created by Markos Charatzas on 16/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation
import XCTest

@testable import windmill

class NSFileManagerTest : XCTestCase
{
    
    func testGivenWindmillHomeDirectoryURLAssertPath(){
        
        let url = FileManager.default.windmillHomeDirectoryURL
        
        XCTAssertEqual("/Users/qnoid/.windmill", url.path)
    }
    
    func testGivenBuildDirectoryURLAssertPath() {
        let buildDirectoryURL = FileManager.default.buildDirectoryURL(forProject: "foo")
        
        XCTAssertEqual("/Users/qnoid/.windmill/foo/build", buildDirectoryURL.path)
    }
    
    func testGivenArchiveInfoURLAssertPath() {
        let archiveInfoURL = FileManager.default.archiveInfoURL(forProject: "foo", inArchive: "bar")
        
        XCTAssertEqual("/Users/qnoid/.windmill/foo/build/bar.xcarchive/Info.plist", archiveInfoURL.path)
    }

}
