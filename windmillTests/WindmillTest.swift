//
//  WindmillTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 30/06/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import XCTest

@testable import windmill

class WindmillMock: Windmill {
    
    let expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
        super.init(keychain: Keychain.defaultKeychain())
    }
    
    override func didComplete(type: ActivityType, success: Bool, error: Error?) {
        XCTAssertFalse(success)
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, 128)
        expectation.fulfill()
    }
}

class WindmillTest: XCTestCase {

    func testGivenErrorAssertDidCompleteCalled() {
        
        let repoName = "any"
        let url = FileManager.default.trashDirectoryURL.appendingPathComponent(repoName)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        let process = Process.makeCheckout(windmillHomeDirectoryURL: FileManager.default.trashDirectoryURL, repoName: repoName, origin: "invalid")
        
        defer {
            try? FileManager.default.removeItem(at: url)
        }

        let expectation = self.expectation(description: #function)
        
        let windmill = WindmillMock(expectation: expectation)
        
        windmill.deploy(project: Project(name: repoName, scheme: "any", origin: "invalid"), at: url.path) { (_, _, _) in
            
        }        
        
        wait(for: [expectation], timeout: 5.0)
    }
}
