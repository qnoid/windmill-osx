//
//  WindmillTest.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 30/06/2017.
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

class ActivityManagerMock: ActivityManager {
    let expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation, subscriptionManager: SubscriptionManager, processManager: ProcessManager) {
        self.expectation = expectation
        super.init(subscriptionManager: subscriptionManager, processManager: processManager)
    }
    
    override func didTerminate(manager: ProcessManager, process: Process, status: Int32, userInfo: [AnyHashable : Any]?) {
        XCTAssertEqual(status, 128)
        expectation.fulfill()
    }
}

class WindmillMock: Windmill {
    
    init(expectation: XCTestExpectation, project: Project) {
        let subscriptionManager = SubscriptionManager()
        super.init(configuration: Windmill.Configuration.make(project: project), locations: Locations.make(project: project), subscriptionManager: subscriptionManager)
        
        let processManager = ProcessManager()
        
        self.activityManager = ActivityManagerMock(expectation: expectation, subscriptionManager: subscriptionManager, processManager: processManager)
    }
}

struct MetadataMock: Metadata {
    var url: URL
    
    var dictionary: [String : Any]?
}

class WindmillTest: XCTestCase {
    
    let bundle = Bundle(for: ProcessChainTest.self)
    
    override func setUp() {
        continueAfterFailure = false
    }
    
    func testGivenProjectWithNoTestTargetAssertExitAfterRecover() {
        
        let expectation = XCTestExpectation(description: #function)
        
        let name = "helloword-no-test-target"
        let repositoryLocalURL = bundle.url(forResource: name, withExtension: "")!
        
        let project = Project(isWorkspace: false, name: name, scheme: name, origin: "any")
        let windmill = Windmill.make(project: project)
        
        let activities = Activities(project: project, windmill: windmill)
        
        activities.activityBuild(locationURL: repositoryLocalURL, next: { _ in
            expectation.fulfill()
        })(["projectAt":Project.Location(project: project, url: repositoryLocalURL)])
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testGivenProjectWithTestTargetAssertExitSuccesfully() {
        
        let expectation = XCTestExpectation(description: #function)
        
        let name = "project-with-unit-tests"
        let repositoryLocalURL = bundle.url(forResource: name, withExtension: "")!
        
        let project = Project(isWorkspace: false, name: name, scheme: name, origin: "any")
        let windmill = Windmill.make(project: project)
        
        let activities = Activities(project: project, windmill: windmill)

        activities.activityBuild(locationURL: repositoryLocalURL, next: { _ in
            expectation.fulfill()
        })(["projectAt":Project.Location(project: project, url: repositoryLocalURL)])
        
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testGivenProjectWithBuildErrorsAssertErrorSummary() {
        
        let expectation = XCTestExpectation(description: #function)
        
        let name = "project-with-build-errors"
        let repositoryLocalURL = bundle.url(forResource: name, withExtension: "")!
        
        let project = Project(isWorkspace: false, name: name, scheme: name, origin: "any")
        let windmill = Windmill.make(project: project)
        
        NotificationCenter.default.addObserver(forName: Windmill.Notifications.didError, object: windmill, queue: OperationQueue.main) { notification in
            let errorCount = notification.userInfo?["errorCount"] as? Int
            let errorSummaries = notification.userInfo?["errorSummaries"] as? [ResultBundle.ErrorSummary]
            
            XCTAssertEqual(5, errorCount)
            XCTAssertNotNil(errorSummaries)
            expectation.fulfill()
        }
        
        let activities = Activities(project: project, windmill: windmill)

        activities.activityBuild(locationURL: repositoryLocalURL, next: { _ in
            })(["projectAt":Project.Location(project: project, url: repositoryLocalURL)])
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testGivenProjectWithoutTestTargetAssertTestWasSuccesful() {
        
        let expectation = XCTestExpectation(description: #function)
        let processManager = ProcessManager()
        var monitor: ProcessMonitor? = ProcessMonitorFailOnUnsuccessfulExit()
        
        let name = "helloword-no-test-target"
        let repositoryLocalURL = bundle.url(forResource: name, withExtension: "")!
        
        let buildSettings = BuildSettings(url: bundle.url(forResource: "/metadata/\(name)/build/settings", withExtension: "json")!)
        
        defer {
            monitor = nil //just a way to keep the monitor reference arround for the test execution
        }
        
        let project = Project(isWorkspace: false, name: name, scheme: "helloword-no-test-target", origin: "any")
        let windmill = Windmill.make(project: project, processManager: processManager)
        processManager.monitor = monitor

        let activities = Activities(project: project, windmill: windmill)
        
        activities.activityTest(locationURL: repositoryLocalURL, buildSettings: buildSettings) { _ in
            expectation.fulfill()
            }(["buildSettings":buildSettings.for(project: project.name)])

        wait(for: [expectation], timeout: 30.0)
    }
    
    func testGivenProjectWithTestTargetAssertTestWasSuccesful() {
        
        let expectation = XCTestExpectation(description: #function)
        let processManager = ProcessManager()
        var monitor: ProcessMonitor? = ProcessMonitorFailOnUnsuccessfulExit()
        
        let name = "helloworld"
        
        let repositoryLocalURL = bundle.url(forResource: name, withExtension: "")!
        
        defer {
            monitor = nil //just a way to keep the monitor reference arround for the test execution
        }
        
        let project = Project(isWorkspace: false, name: name, scheme: "helloworld", origin: "any")
        let windmill = Windmill.make(project: project, processManager: processManager)
        processManager.monitor = monitor

        let buildSettings = BuildSettings(url: bundle.url(forResource: "/metadata/\(name)/build/settings", withExtension: "json")!)
        
        let activities = Activities(project: project, windmill: windmill)
        
        activities.activityTest(locationURL: repositoryLocalURL, buildSettings: buildSettings) { _ in
                expectation.fulfill()
            }(["buildSettings":buildSettings.for(project: project.name)])
        
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testGivenProjectWithoutAvailableSimulatorAssertTestWasSuccesful() {
        
        let expectation = XCTestExpectation(description: #function)
        let processManager = ProcessManager()
        var monitor: ProcessMonitor? = ProcessMonitorFailOnUnsuccessfulExit()
        
        let name = "no_simulator_available"
        let repositoryLocalURL = bundle.url(forResource: name, withExtension: "")!
        
        defer {
            monitor = nil //just a way to keep the monitor reference arround for the test execution
        }
        
        let project = Project(isWorkspace: false, name: name, scheme: "no_simulator_available", origin: "any")
        let windmill = Windmill.make(project: project, processManager: processManager)
        processManager.monitor = monitor

        let buildSettings = BuildSettings(url: bundle.url(forResource: "/metadata/\(name)/build/settings", withExtension: "json")!)
        
        let activities = Activities(project: project, windmill: windmill)
        
        activities.activityTest(locationURL: repositoryLocalURL, buildSettings: buildSettings) { _ in
            expectation.fulfill()
            }(["buildSettings":buildSettings.for(project: project.name)])

        wait(for: [expectation], timeout: 30.0)
    }
    
    func testGivenErrorAssertDidExitCalled() {
        
        let repoName = "any"
        let project = Project(isWorkspace: false, name: repoName, scheme: "any", origin: "invalid")
        
        let expectation = self.expectation(description: #function)
        
        let windmill = WindmillMock(expectation: expectation, project: project)
        
        windmill.run()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
}
