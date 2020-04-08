//
//  WindmillTest.swift
//  IntegrationTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 12/03/2019.
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
