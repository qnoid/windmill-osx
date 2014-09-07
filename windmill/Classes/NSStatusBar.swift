//
//  NSStatusBar.swift
//  windmill
//
//  Created by Markos Charatzas on 07/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import AppKit
import Foundation

extension NSStatusBar
{
    class func systemStatusItem(menu: NSMenu) -> NSStatusItem
    {
        let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(20)
        statusItem.menu = menu
        statusItem.enabled = true
        statusItem.highlightMode = true

    return statusItem
    }
}