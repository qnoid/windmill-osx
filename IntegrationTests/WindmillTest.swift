//
//  WindmillTest.swift
//  IntegrationTests
//
//  Created by Markos Charatzas on 12/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class WindmillTimer {
    
    let expectation: XCTestExpectation
    var startDate: Date?
    var executionTime = 0.0
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func observe(windmill: Windmill) {
        NotificationCenter.default.addObserver(self, selector: #selector(willRun(_:)), name: Windmill.Notifications.willRun, object: windmill)
        NotificationCenter.default.addObserver(self, selector: #selector(willMonitorProject(_:)), name: Windmill.Notifications.isMonitoring, object: windmill)
        NotificationCenter.default.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.didError, object: windmill)
    }
    
    @objc func willRun(_ aNotification: Notification) {
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

class WindmillTest: XCTestCase {

    /**
     - Precondition: requires internet connection
     */
    func testGivenWindmillRunAssertTimeTaken() {
        
        let expectation = self.expectation(description: #function)
        
        let name = "helloword-no-test-target"
        let project = Project(isWorkspace: false, name: name, scheme: "helloworld", origin: "git@github.com:qnoid/helloword-no-test-target.git")
        let timer = WindmillTimer(expectation: expectation)
        let windmill = Windmill.make(project: project)
        
        timer.observe(windmill: windmill)
        windmill.run()
        
        wait(for: [expectation], timeout: 90.0)
        XCTAssertLessThanOrEqual(timer.executionTime, 45.0)
    }
}
