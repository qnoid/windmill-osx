//
//  ShowTabOverviewToolbarItem.swift
//  windmill
//
//  Created by Markos Charatzas on 29/05/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Cocoa

class ShowTabOverviewToolbarItem: NSToolbarItem {
    
    override func validate() {
        let count = NSApplication.shared.keyWindow?.tabbedWindows?.count ?? 0
        
        self.isEnabled = count > 0
    }
}
