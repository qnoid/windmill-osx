//
//  MainWindowController.swift
//  windmill
//
//  Created by Markos Charatzas on 10/01/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit


class MainWindowController: NSWindowController {
    
    private lazy var projectTitlebarAccessoryViewController: ProjectTitlebarAccessoryViewController = { [weak storyboard = self.storyboard] in
        storyboard?.instantiateControllerWithIdentifier("ProjectTitlebarAccessoryViewController") as! ProjectTitlebarAccessoryViewController
        }()
    

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window!.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        self.window!.collectionBehavior = [self.window!.collectionBehavior, .FullScreenAllowsTiling]
        self.window?.addTitlebarAccessoryViewController(self.projectTitlebarAccessoryViewController)

        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "mainWindowDidLoad", object: self))
    }
}