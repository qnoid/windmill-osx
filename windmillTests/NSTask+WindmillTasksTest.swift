//
//  NSTask+WindmillTasksTest.swift
//  windmill
//
//  Created by Markos Charatzas on 19/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation
import XCTest
@testable import windmill

class NSTaskTest : XCTestCase
{
    func testGivenArchiveTaskAssertStatus()
    {
        let expectation = self.expectationWithDescription(__FUNCTION__)
        let archive = NSTask.taskArchive(directoryPath: "~/.windmill/brainmap", projectName: "brainmap")

        var actual: TaskStatus?
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)){
            archive.launch()
            archive.waitUntilStatus{ status in
                actual = status
                expectation.fulfill()
            }
        }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)

        XCTAssertNotNil(actual)
        XCTAssertEqual(actual?.value, 65, actual!.description)
    }
}