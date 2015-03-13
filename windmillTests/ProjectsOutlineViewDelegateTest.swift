//
//  ProjectsOutlineViewDelegateTest.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Cocoa
import AppKit
import XCTest
import windmill

extension MainWindowController
{
    class func loadMainWindowController() -> MainWindowController
    {
        let mainWindowViewController = MainWindowController.mainWindowController()
        let loadWindow = mainWindowViewController.window
        return mainWindowViewController
    }
}

class ProjectsOutlineViewDelegateTest: XCTestCase {

    func testGivenMainOutlineViewAssertProjectNameSetOnTableCell()
    {
        let mainWindowViewController = MainWindowController.loadMainWindowController()
        
        let name = "a name"
        let project = Project(name: name, origin: "foo")
        let delegate = ProjectsOutlineViewDelegate()

        let cell = delegate.outlineView(mainWindowViewController.outlineView, viewForTableColumn:nil, item:project) as! NSTableCellView
        
        XCTAssertNotNil(cell.textField!.stringValue, "Name should be set")
        XCTAssertEqual(name, cell.textField!.stringValue, "Name should be set")
    }

    func testGivenMainOutlineViewAssertHeaderSetOnTableCell()
    {
        let mainWindowViewController = MainWindowController.loadMainWindowController()
        let delegate = ProjectsOutlineViewDelegate()
        let header : Header = "a header"
        
        let cell = delegate.outlineView(mainWindowViewController.outlineView, viewForTableColumn:nil, item:header) as! NSTableCellView
        
        XCTAssertNotNil(cell.textField!.stringValue, "Header name should be set")
        XCTAssertEqual(header, cell.textField!.stringValue, "Name should be set")
    }

}
