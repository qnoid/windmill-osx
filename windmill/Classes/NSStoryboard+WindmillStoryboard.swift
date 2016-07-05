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
            return NSStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        }
        
        static func mainWindowController() -> MainWindowController {
            return self.mainStoryboard().instantiateInitialController() as! MainWindowController
        }
    }
}