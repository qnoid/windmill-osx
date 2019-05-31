//
//  NSFileManagerTest.swift
//  windmill
//
//  Created by Markos Charatzas on 16/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation
import XCTest

@testable import Windmill

class NSFileManagerTest : XCTestCase
{
    
    func testGivenWindmillHomeDirectoryURLAssertPath(){
        
        let url = FileManager.default.windmillDirectory.URL
        
        XCTAssertEqual("/Users/qnoid/.windmill", url.path)
    }
    
    func testGivenBuildDirectoryURLAssertPath() {
        let buildDirectoryURL = FileManager.default.windmillDirectory.directory(for: Project(isWorkspace: false, name: "foo", scheme: "schmee", origin: "any")).buildDirectoryURL()
        
        XCTAssertEqual("/Users/qnoid/.windmill/foo/build", buildDirectoryURL.path)
    }
    
    func testGivenTestDirectoryURLAssertPath() {
        let testDirectoryURL = FileManager.default.windmillDirectory.directory(for: Project(isWorkspace: false, name: "foo", scheme: "schmee", origin: "any")).testDirectoryURL()
        
        XCTAssertEqual("/Users/qnoid/.windmill/foo/test", testDirectoryURL.path)
    }

    func testGivenArchiveDirectoryURLAssertPath() {
        let archiveDirectoryURL = FileManager.default.windmillDirectory.directory(for: Project(isWorkspace: false, name: "foo", scheme: "schmee", origin: "any")).archiveDirectoryURL()
        
        XCTAssertEqual("/Users/qnoid/.windmill/foo/archive", archiveDirectoryURL.path)
    }

    func testGivenArchiveInfoURLAssertPath() {
        let archive = FileManager.default.windmillDirectory.directory(for: Project(isWorkspace: false, name: "foo", scheme: "schmee", origin: "any")).archive(name: "bar")
        
        XCTAssertEqual("/Users/qnoid/.windmill/foo/archive/bar.xcarchive/Info.plist", archive.info.url.path)
    }

    func testGivenExportDirectoryURLAssertPath() {
        let exportDirectoryURL = FileManager.default.windmillDirectory.directory(for: Project(isWorkspace: false, name: "foo", scheme: "schmee", origin: "any")).exportDirectoryURL()
        
        XCTAssertEqual("/Users/qnoid/.windmill/foo/export", exportDirectoryURL.path)
    }

    func testGivenPollDirectoryURLAssertPath() {
        let pollDirectoryURL = FileManager.default.windmillDirectory.directory(for: Project(isWorkspace: false, name: "foo", scheme: "schmee", origin: "any")).pollURL()
        
        XCTAssertEqual("/Users/qnoid/.windmill/foo/poll", pollDirectoryURL.path)
    }

}
