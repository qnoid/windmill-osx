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
    
    init(expectation: XCTestExpectation, project: Project) {
        self.expectation = expectation
        super.init(processManager: ProcessManager(), project: project)
    }
    
    override func didExit(manager: ProcessManager, process: Process, isSuccess: Bool, userInfo: [AnyHashable : Any]?) {
        XCTAssertFalse(isSuccess)
        XCTAssertEqual(process.terminationStatus, 128)
        expectation.fulfill()
    }
}

class WindmillTest: XCTestCase {

    func testGivenErrorAssertDidExitCalled() {
        
        let repoName = "any"
        let project = Project(name: repoName, scheme: "any", origin: "invalid")

        let url = FileManager.default.trashDirectoryURL.appendingPathComponent(repoName)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        let process = Process.makeCheckout(projectDirectoryURL: FileManager.default.trashDirectoryURL, repoName: repoName, origin: "invalid")
        
        defer {
            try? FileManager.default.removeItem(at: url)
        }

        let expectation = self.expectation(description: #function)
        
        let windmill = WindmillMock(expectation: expectation, project: project)
        
        let repeatableDeploy = windmill.repeatableDeploy(user: "user")
        windmill.run(sequence: repeatableDeploy)

        wait(for: [expectation], timeout: 5.0)
    }
}
