//
//  ProcessManagerTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 16/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import XCTest

@testable import windmill

class ProcessManagerMonitorWillDidLaunch: ProcessMonitor {
    let expectationWillLaunch: XCTestExpectation
    let expectationDidLaunch: XCTestExpectation
    
    init(expectationWillLaunch: XCTestExpectation, expectationDidLaunch: XCTestExpectation) {
        self.expectationWillLaunch = expectationWillLaunch
        self.expectationDidLaunch = expectationDidLaunch
    }
    
    func willLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?) {
        expectationWillLaunch.fulfill()

    }
    
    func didLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?) {
        expectationDidLaunch.fulfill()
    }
    
    func didExit(manager: ProcessManager, process: Process, isSuccess: Bool, userInfo: [AnyHashable : Any]?) {

    }
}

class WillExitWithErrorExpectation: ProcessMonitor {
    
    let expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func willLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?) {
        
    }
    
    func didLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?) {
        
    }
    
    func didExit(manager: ProcessManager, process: Process, isSuccess: Bool, userInfo: [AnyHashable : Any]?) {
        XCTAssertFalse(isSuccess)
        XCTAssertFalse(process.terminationStatus == 0)
        expectation.fulfill()
    }
}

class ProcessManagerTest: XCTestCase {

    func testGivenNameWithWhitespacesAssertSuccess() {
        let manager = ProcessManager()
        let repoName = "with white space"
        let validOrigin = "git@github.com:windmill-io/blank.git"
        let process = Process.makeCheckout(projectDirectoryURL: FileManager.default.trashDirectoryURL, repoName: repoName, origin: validOrigin)
        
        defer {
            var trashDirectory = FileManager.default.trashDirectoryURL
            try? FileManager.default.removeItem(at: trashDirectory.appendingPathComponent(repoName))
        }
        
        let expectation = self.expectation(description: #function)
        
        let checkout = manager.sequence(process: process, wasSuccesful: DispatchWorkItem {
            expectation.fulfill()
        })
        
        checkout.launch()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGivenInvalidOriginAssertError() {
        let manager = ProcessManager()
        let repoName = "any"
        let url = FileManager.default.trashDirectoryURL.appendingPathComponent(repoName)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        let process = Process.makeCheckout(projectDirectoryURL: FileManager.default.trashDirectoryURL, repoName: repoName, origin: "invalid")
        
        defer {
            try? FileManager.default.removeItem(at: url)
        }
        
        let expectation = self.expectation(description: #function)
        let monitor = WillExitWithErrorExpectation(expectation: expectation)
        manager.monitor = monitor
        let sequence = manager.sequence(process: process)
        
        sequence.launch()

        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGivenWorkItemAssertCompletionHandlerCalled() {
        let manager = ProcessManager()
        
        let process = Process()
        process.launchPath = "/bin/echo"
        process.arguments = ["Hello World"]
        
        let expectation = XCTestExpectation()
        
        let sequence = manager.sequence(process: process, wasSuccesful: DispatchWorkItem {
            expectation.fulfill()
        })
        
        DispatchQueue.main.async {
            sequence.launch()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    
    func testGivenWorkItemAssertWillLaunchDidLaunchOrder() {
        let expectationWillLaunch = XCTestExpectation()
        let expectationDidLaunch = XCTestExpectation()
        
        let monitor = ProcessManagerMonitorWillDidLaunch(expectationWillLaunch: expectationWillLaunch, expectationDidLaunch: expectationDidLaunch)
        
        let manager = ProcessManager()
        manager.monitor = monitor
        
        let process = Process()
        process.launchPath = "/bin/echo"
        process.arguments = ["Hello World"]
        
        
        let sequence = manager.sequence(process: process)
        
        DispatchQueue.main.async {
            sequence.launch()
        }
        
        wait(for: [expectationWillLaunch, expectationDidLaunch], timeout: 5.0, enforceOrder: true)
    }
}
