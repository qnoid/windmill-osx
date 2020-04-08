//
//  ProcessManagerTest.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 16/08/2017.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
//

import XCTest

@testable import Windmill

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
    
    func didExit(manager: ProcessManager, process: Process, isSuccess: Bool, canRecover: Bool, userInfo: [AnyHashable : Any]?) {

    }
}

class ProcessManagerMonitorCanRecover: ProcessMonitor {
    
    func willLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?) {
        
    }
    
    func didLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?) {
    }
    
    func didExit(manager: ProcessManager, process: Process, isSuccess: Bool, canRecover: Bool, userInfo: [AnyHashable : Any]?) {
        XCTAssertTrue(canRecover)
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
    
    func didExit(manager: ProcessManager, process: Process, isSuccess: Bool, canRecover: Bool, userInfo: [AnyHashable : Any]?) {
        XCTAssertFalse(isSuccess)
        XCTAssertFalse(process.terminationStatus == 0)
        expectation.fulfill()
    }
}

class ProcessManagerTest: XCTestCase {

    let bundle: Bundle = Bundle(for: ProcessManagerTest.self)
    
    func testGivenInvalidOriginAssertError() {
        let manager = ProcessManager()
        let repoName = "any"
        let url = FileManager.default.trashDirectoryURL.appendingPathComponent(repoName)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        let process = Process.makeCheckout(sourceDirectory: FileManager.default.directory(FileManager.default.trashDirectoryURL), project: Project(isWorkspace: false, name: repoName, scheme: "foo", origin: "invalid"), log: FileManager.default.trashDirectoryURL)
        
        defer {
            try? FileManager.default.removeItem(at: url)
        }
        
        let expectation = self.expectation(description: #function)
        let monitor = WillExitWithErrorExpectation(expectation: expectation)
        manager.monitor = monitor
        manager.launch(process: process)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGivenWorkItemAssertCompletionHandlerCalled() {
        let manager = ProcessManager()
        
        let process = Process()
        process.launchPath = "/bin/echo"
        process.arguments = ["Hello World"]
        
        let expectation = XCTestExpectation()
        
        DispatchQueue.main.async {
            manager.launch(process: process, wasSuccesful: { _ in
                expectation.fulfill()
            })            
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
        
        
        DispatchQueue.main.async {
            manager.launch(process: process)
        }
        
        wait(for: [expectationWillLaunch, expectationDidLaunch], timeout: 5.0, enforceOrder: true)
    }
    
    func testGivenRecoverOnRoute66AssertCanRecover() {
        
        let canRecover = self.expectation(description: #function)
        let monitor = ProcessManagerMonitorCanRecover()

        let manager = ProcessManager()
        manager.monitor = monitor
        
        let process = Process()
        process.launchPath = Bundle(for: ProcessManagerTest.self).url(forResource: "exit", withExtension: "sh")?.path
        process.arguments = ["66"]

        let route66 = RecoverableProcess.recover(terminationStatus: 66) { (_) in
            canRecover.fulfill()
        }
        
        DispatchQueue.main.async {
            manager.launch(process: process, recover: route66)
        }
        
        wait(for: [canRecover], timeout: 5.0)
    }
    
    func testGivenFindProjectAssertProcessResult() {
        
        let expectation = self.expectation(description: #function)

        let manager = ProcessManager()

        let project = Project(isWorkspace: false, name: "project-not-at-root", scheme: "project-not-at-root", origin: "any")
        let repositoryLocalURL = bundle.url(forResource: "project-not-at-root", withExtension: "")!
        
        let process = Process.makeFind(project: project, repositoryLocalURL: repositoryLocalURL)

        var actual: ProcessManager.StandardOutput?
        manager.launch(process: process) { standardOutput in
            actual = standardOutput
            expectation.fulfill()
        }
     
        wait(for: [expectation], timeout: 5.0)

        XCTAssertTrue(actual!.isSuccess)
        XCTAssertEqual(actual!.terminationStatus, 0)
        
        XCTAssertEqual(actual!.value, "/Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-fezcvdrmroaraabfbnktjikmxgvk/Build/Products/Debug/Windmill.app/Contents/PlugIns/windmillTests.xctest/Contents/Resources/project-not-at-root/iOS")
    }
}
