//
//  ProjectsDataSourceTest.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Cocoa
import XCTest
import windmill

class ProjectsDataSourceTest: XCTestCase {
    
    func testGivenProjectAssertAddTrue()
    {
        let datasource = ProjectsDataSource.projectsDataSource()
        let project = Project(name: "foo", origin: "bar")
        
        XCTAssertTrue(datasource.add(project), "Project should have been added to the datasource")
    }
    
    func testGivenSameProjectAssertAddFalse()
    {
        let datasource = ProjectsDataSource.projectsDataSource()
        let project = Project(name: "foo", origin: "bar")
        
        datasource.add(project)
        
        XCTAssertFalse(datasource.add(project), "Project should have been rejected since already added")
    }

}
