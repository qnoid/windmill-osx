//
//  AppDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 07/06/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import AppKit
import Foundation

private let userIdentifier = NSUUID().UUIDString;

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, WindmillViewDelegate
{
    @IBOutlet var menu : NSMenu!
    
    var keychain : Keychain {
        return Keychain.defaultKeychain()
    }
    
    var scheduler : Scheduler!
    
    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        self.keychain.createUser(userIdentifier)

        self.scheduler = Scheduler()

        let statusItem = NSStatusBar.systemStatusItem(self.menu)
        
        let windmillView = WindmillView(frame: NSMakeRect(0, 0, 20, 19))
        windmillView.delegate = self
        windmillView.statusItem = statusItem;
        statusItem.view = windmillView;
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }
    
    func about()
    {
        
    }
    
    func menuWillOpen(menu: NSMenu) {

    }
    
    func didPerformDragOperationWithFolder(localGitRepo: String) {
        self.deployGitRepo(localGitRepo)
    }
        
    func deployGitRepo(localGitRepo : String)
    {
        if let user = self.keychain.findWindmillUser(){
        let deployGitRepoForUserTask = NSTask.taskDeploy(localGitRepo:localGitRepo, forUser:user)
            
        self.scheduler.launch(deployGitRepoForUserTask)
        self.scheduler.schedule {
            return NSTask.taskPoll(localGitRepo)
            }(ifDirty: {
                [unowned self] in
                self.deployGitRepo(localGitRepo)
            })
        }
    }
}

