//
//  MainWindowController.swift
//  windmill
//
//  Created by Markos Charatzas on 10/01/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit


class MainWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        print(#function)
        self.window!.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        self.window!.collectionBehavior = [self.window!.collectionBehavior, .FullScreenAllowsTiling]

        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "mainWindowDidLoad", object: self))
    }
}