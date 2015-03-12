//
//  ProjectTest.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Cocoa
import XCTest
import windmill

class ProjectTest: XCTestCase {

    func testEquatable()
    {
        let sameOrigin = "origin"
        let this = Project("foo", sameOrigin)
        let that = Project("foo", sameOrigin)
        
        XCTAssertTrue(this == that, "Projects with same origin should be equal.")
    }
    
    func testNonEquatable()
    {
        let this = Project("foo", "this")
        let that = Project("foo", "that")
        
        XCTAssertFalse(this == that, "Projects without the same origin should not be equal.")
    }
    
    func testHashable()
    {
        let sameOrigin = "origin"
        let this = Project("foo", sameOrigin)
        let that = Project("foo", sameOrigin)
        
        var set : Set<Project> = []
        set.insert(this)
        set.insert(that)
        
        XCTAssertEqual(1, set.count, "Set should only have one project of the same origin.")
    }
    
    func testNonHashable()
    {
        let this = Project("foo", "this")
        let that = Project("foo", "that")
        
        var set : Set<Project> = []
        set.insert(this)
        set.insert(that)
        
        XCTAssertEqual(2, set.count, "Set should have two projects of different origin.")
    }
}
