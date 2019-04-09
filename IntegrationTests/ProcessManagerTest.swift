//
//  ProcessManagerTest.swift
//  IntegrationTests
//
//  Created by Markos Charatzas on 12/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class ProcessManagerTest: XCTestCase {

    /**
     - Precondition: requires internet connection
     */
    func testGivenNameWithWhitespacesAssertSuccess() {
        let manager = ProcessManager()
        let repoName = "with white space"
        let validOrigin = "git@github.com:windmill-io/blank.git"
        let checkoutDirectory: Directory = FileManager.default.directory(FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random(characters: CharacterSet.lowercaseLetters, length: 16)))
        
        let process = Process.makeCheckout(sourceDirectory: checkoutDirectory, project: Project(name: repoName, scheme: "foo", origin: validOrigin), log: FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random()))
        
        defer {
            var trashDirectory = FileManager.default.trashDirectoryURL
            try? FileManager.default.removeItem(at: trashDirectory.appendingPathComponent(repoName))
        }
        
        let expectation = self.expectation(description: #function)
        
        manager.launch(process: process, wasSuccesful: { _ in
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 5.0)
    }
}
