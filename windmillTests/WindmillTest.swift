//
//  WindmillTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 30/06/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class ActivityManagerMock: ActivityManager {
    let expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation, accountResource: AccountResource, processManager: ProcessManager) {
        self.expectation = expectation
        super.init(accountResource: accountResource, processManager: processManager)
    }
    
    override func didTerminate(manager: ProcessManager, process: Process, status: Int32, userInfo: [AnyHashable : Any]?) {
        XCTAssertEqual(status, 128)
        expectation.fulfill()
    }
}

class WindmillMock: Windmill {
    
    init(expectation: XCTestExpectation, project: Project) {
        super.init(configuration: Windmill.Configuration.make(project: project))
        
        let accountResource = AccountResource()
        let processManager = ProcessManager()
        
        self.activityManager = ActivityManagerMock(expectation: expectation, accountResource: accountResource, processManager: processManager)
    }
}

class WindmillTimer {
    
    let expectation: XCTestExpectation
    var startDate: Date?
    var executionTime = 0.0
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func observe(windmill: Windmill) {
        NotificationCenter.default.addObserver(self, selector: #selector(willStartProject(_:)), name: Windmill.Notifications.willStartProject, object: windmill)
        NotificationCenter.default.addObserver(self, selector: #selector(willMonitorProject(_:)), name: Windmill.Notifications.willMonitorProject, object: windmill)
        NotificationCenter.default.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.didError, object: windmill)
    }
    
    @objc func willStartProject(_ aNotification: Notification) {
        self.startDate = Date()
    }
    
    @objc func willMonitorProject(_ aNotification: Notification) {
        
        let methodFinish = Date()
        self.executionTime = methodFinish.timeIntervalSince(self.startDate!)
        
        expectation.fulfill()
    }
    
    @objc func activityError(_ aNotification: Notification) {
        XCTFail()
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
        
        let project = Project(name: name, scheme: name, origin: "any")
        let windmill = Windmill.make(project: project)
        
        let activities = Activities(project: project, windmill: windmill)
        
        activities.activityBuild(locationURL: repositoryLocalURL, next: { _ in
            expectation.fulfill()
        })(["location":Project.Location(url: repositoryLocalURL)])
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testGivenProjectWithTestTargetAssertExitSuccesfully() {
        
        let expectation = XCTestExpectation(description: #function)
        
        let name = "project-with-unit-tests"
        let repositoryLocalURL = bundle.url(forResource: name, withExtension: "")!
        
        let project = Project(name: name, scheme: name, origin: "any")
        let windmill = Windmill.make(project: project)
        
        let activities = Activities(project: project, windmill: windmill)

        activities.activityBuild(locationURL: repositoryLocalURL, next: { _ in
            expectation.fulfill()
        })(["location":Project.Location(url: repositoryLocalURL)])
        
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testGivenProjectWithBuildErrorsAssertErrorSummary() {
        
        let expectation = XCTestExpectation(description: #function)
        
        let name = "project-with-build-errors"
        let repositoryLocalURL = bundle.url(forResource: name, withExtension: "")!
        
        let project = Project(name: name, scheme: name, origin: "any")
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
            })(["location":Project.Location(url: repositoryLocalURL)])
        
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
        
        let project = Project(name: name, scheme: "helloword-no-test-target", origin: "any")
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
        
        let project = Project(name: name, scheme: "helloworld", origin: "any")
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
        
        let project = Project(name: name, scheme: "no_simulator_available", origin: "any")
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
        let project = Project(name: repoName, scheme: "any", origin: "invalid")
        
        let expectation = self.expectation(description: #function)
        
        let windmill = WindmillMock(expectation: expectation, project: project)
        
        windmill.run(project, skipCheckout: false, user: "user")
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    /**
     - Precondition: requires internet connection
     */
    func testGivenWindmillRunAssertTimeTaken() {
        
        let expectation = self.expectation(description: #function)
        
        let name = "helloword-no-test-target"
        let project = Project(name: name, scheme: "helloworld", origin: "git@github.com:qnoid/helloword-no-test-target.git")
        let timer = WindmillTimer(expectation: expectation)
        let windmill = Windmill.make(project: project)
        
        timer.observe(windmill: windmill)
        windmill.run(project, skipCheckout: false, user: "14810686-4690-4900-ada5-8b0b7338aa39")
        
        wait(for: [expectation], timeout: 90.0)
        XCTAssertLessThanOrEqual(timer.executionTime, 45.0)
    }
}
