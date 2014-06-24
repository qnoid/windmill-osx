//
//  AppDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 07/06/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var menu : NSMenu?
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        
        self.menu = NSMenu()

        let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(CGFloat(NSVariableStatusItemLength))
        self.statusItem = statusItem;
        statusItem.enabled = true
        statusItem.highlightMode = true
        statusItem.view = FooView(frame: NSMakeRect(0, 0, 20, 19))
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }


    func about()
    {
        
    }
}

