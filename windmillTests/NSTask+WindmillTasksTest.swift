//
//  NSTask+WindmillTasksTest.swift
//  windmill
//
//  Created by Markos Charatzas on 19/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation
import XCTest
import windmill

class NSTaskTest : XCTestCase
{
    func testDevelopmentBuildProjectIsCreated()
    {
        _ = NSTask.taskDevelopmentBuildProject(directoryPath: "foo")
        
        XCTAssertTrue(true, "Task created without any exceptions")
    }
    
    func testDevelopmentBuildWorkspaceIsCreated()
    {
        _ = NSTask.taskDevelopmentBuildWorkspace(directoryPath: "foo")
        
        XCTAssertTrue(true, "Task created without any exceptions")
    }
}