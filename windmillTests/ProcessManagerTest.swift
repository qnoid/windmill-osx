//
//  ProcessManagerTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 16/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import XCTest

@testable import windmill

class ProcessManagerDelegateWillDidLaunch: ProcessManagerDelegate {
    
    let expectationWillLaunch: XCTestExpectation
    let expectationDidLaunch: XCTestExpectation
    
    init(expectationWillLaunch: XCTestExpectation, expectationDidLaunch: XCTestExpectation) {
        self.expectationWillLaunch = expectationWillLaunch
        self.expectationDidLaunch = expectationDidLaunch
    }
    
    func willLaunch(manager: ProcessManager, process: Process, type: ActivityType) {
        expectationWillLaunch.fulfill()
    }
    
    func didLaunch(manager: ProcessManager, process: Process, type: ActivityType) {
        expectationDidLaunch.fulfill()
    }
}

class ProcessManagerTest: XCTestCase {

    func testGivenNameWithWhitespacesAssertSuccess() {
        let manager = ProcessManager()
        let repoName = "with white space"
        let validOrigin = "git@github.com:windmill-io/blank.git"
        let process = Process.makeCheckout(directoryPath: FileManager.default.trashDirectoryURL.path, repoName: repoName, origin: validOrigin)
        
        defer {
            var trashDirectory = FileManager.default.trashDirectoryURL
            try? FileManager.default.removeItem(at: trashDirectory.appendingPathComponent(repoName))
        }
        
        let expectation = self.expectation(description: #function)
        
        let workItem = manager.makeDispatchWorkItem(process: process, type: .checkout) { (type, success, error) in
            XCTAssertEqual(type, .checkout)
            XCTAssertTrue(success)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        DispatchQueue.main.async(execute: workItem)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGivenInvalidOriginAssertError() {
        let manager = ProcessManager()
        let repoName = "any"
        let url = FileManager.default.trashDirectoryURL.appendingPathComponent(repoName)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        let process = Process.makeCheckout(directoryPath: FileManager.default.trashDirectoryURL.path, repoName: repoName, origin: "invalid")
        
        defer {
            try? FileManager.default.removeItem(at: url)
        }
        
        let expectation = self.expectation(description: #function)
        
        let workItem = manager.makeDispatchWorkItem(process: process, type: .checkout) { (type, success, error) in
            XCTAssertEqual(type, .checkout)
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            XCTAssertEqual((error as NSError?)?.code, 128)
            expectation.fulfill()
        }
        
        DispatchQueue.main.async(execute: workItem)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGivenWorkItemAssertCompletionHandlerCalled() {
        let manager = ProcessManager()
        
        let process = Process()
        process.launchPath = "/bin/echo"
        process.arguments = ["Hello World"]
        
        let expectation = XCTestExpectation()
        
        let workItem = manager.makeDispatchWorkItem(process: process, type: .checkout) { (type, success, error) in
            expectation.fulfill()
        }
        
        DispatchQueue.main.async(execute: workItem)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    
    func testGivenWorkItemAssertWillLaunchDidLaunchOrder() {
        let expectationWillLaunch = XCTestExpectation()
        let expectationDidLaunch = XCTestExpectation()
        
        let delegate = ProcessManagerDelegateWillDidLaunch(expectationWillLaunch: expectationWillLaunch, expectationDidLaunch: expectationDidLaunch)
        
        var manager = ProcessManager()
        manager.delegate = delegate
        
        let process = Process()
        process.launchPath = "/bin/echo"
        process.arguments = ["Hello World"]
        
        
        let workItem = manager.makeDispatchWorkItem(process: process, type: .checkout) { (type, success, error) in
        }
        
        DispatchQueue.main.async(execute: workItem)
        
        wait(for: [expectationWillLaunch, expectationDidLaunch], timeout: 5.0, enforceOrder: true)
    }
}
