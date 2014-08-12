//
//  AppDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 07/06/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    @IBOutlet var menu : NSMenu?
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(aNotification: NSNotification?)
    {
        let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(20)
        statusItem.menu = self.menu
        self.statusItem = statusItem;
        statusItem.enabled = true
        statusItem.highlightMode = true
        let fooView = FooView(frame: NSMakeRect(0, 0, 20, 19))
        fooView.statusItem = self.statusItem;
        statusItem.view = fooView;
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }


    func about()
    {
        
    }
    
    func menuWillOpen(menu: NSMenu!) {

    }
}

