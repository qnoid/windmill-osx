//
//  NSStatusBar.swift
//  windmill
//
//  Created by Markos Charatzas on 07/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import AppKit
import Foundation


struct Event {
    var action: Selector
    var target: AnyObject?
    var mask: NSEventMask
}

extension NSStatusBar
{
    class func systemStatusItem(menu: NSMenu) -> NSStatusItem
    {
        let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
        statusItem.menu = menu
        statusItem.enabled = true
        statusItem.highlightMode = true

    return statusItem
    }
    
    class func systemStatusItem(menu: NSMenu, event: Event) -> NSStatusItem
    {
        let statusItem = self.systemStatusItem(menu)
        statusItem.action = event.action
        statusItem.target = event.target
        statusItem.sendActionOn(NSEventMask(rawValue: UInt64(Int(event.mask.rawValue))))
        
        return statusItem
    }
}
