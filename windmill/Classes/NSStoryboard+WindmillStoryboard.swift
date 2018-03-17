//
//  NSStoryboard+WindmillStoryboard.swift
//  windmill
//
//  Created by Markos Charatzas on 10/01/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit

extension NSStoryboard
{
    struct Windmill
    {
        static func mainStoryboard() -> NSStoryboard {
            return NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: Bundle.main)
        }
        
        static func mainWindowController() -> MainWindowController {
            return self.mainStoryboard().instantiateInitialController() as! MainWindowController
        }
        
        static func errorSummariesStoryboard() -> NSStoryboard {
            return NSStoryboard(name: NSStoryboard.Name(rawValue: "ErrorSummaries"), bundle: Bundle.main)
        }

        static func testFailureSummariesStoryboard() -> NSStoryboard {
            return NSStoryboard(name: NSStoryboard.Name(rawValue: "TestFailureSummaries"), bundle: Bundle.main)
        }
    }
}
