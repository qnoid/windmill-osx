//
//  BottomTabViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 12/4/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Cocoa

class BottomTabViewController: NSTabViewController {
    
    var consoleViewController: ConsoleViewController? {
        return self.childViewControllers[0] as? ConsoleViewController
    }

    var prettyConsoleViewController: PrettyConsoleViewController? {
        return self.childViewControllers[1] as? PrettyConsoleViewController
    }    
}
