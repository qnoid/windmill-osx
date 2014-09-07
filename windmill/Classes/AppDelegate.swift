//
//  AppDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 07/06/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import AppKit
import Foundation

private let userIdentifier = NSUUID.UUID().UUIDString;

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, WindmillViewDelegate
{
    @IBOutlet var menu : NSMenu?
    
    var keychain : Keychain {
        return Keychain.defaultKeychain()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification?)
    {        
        self.keychain.createUser(userIdentifier)
        
        let statusItem = NSStatusBar.systemStatusItem(self.menu!)
        
        let windmillView = WindmillView(frame: NSMakeRect(0, 0, 20, 19))
        windmillView.delegate = self
        windmillView.statusItem = statusItem;
        statusItem.view = windmillView;
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
    }
    
    func about()
    {
        
    }
    
    func menuWillOpen(menu: NSMenu!) {

    }
    
    func didPerformDragOperationWithFolder(folder: String)
    {
        if let user = self.keychain.findGenericPassword(KeychainAccountIOWindmillUser).password
        {
            let task = WindmillTasks.deployTask(folder, user: user)
            task.launch()
        }
        else
        {
            NSLog("Error querying default keychain for account: '%@' under service '%@'", KeychainAccountIOWindmillUser.name, KeychainAccountIOWindmillUser.serviceName)
        }
    }
}

