//
//  AppDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 07/06/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import AppKit
import Foundation
import os

private let userIdentifier = UUID().uuidString;

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate
{
    @IBOutlet weak var menu: NSMenu! {
        didSet{
            self.statusItem = NSStatusBar.systemStatusItem(self.menu, event:Event(
                action: #selector(AppDelegate.mouseDown(_:)),
                target: self,
                mask: NSEventMask.leftMouseDown
                ))
        }
    }
    
    var statusItem: NSStatusItem! {
        didSet{
            statusItem.toolTip = NSLocalizedString("windmill.toolTip", comment: "")
            
            let image = NSImage(named:"statusItem")!
            image.isTemplate = true
            statusItem.button?.image = image
            statusItem.button?.wantsLayer = true
            self.statusItem.button?.window?.registerForDraggedTypes([NSFilenamesPboardType])
            self.statusItem.button?.window?.delegate = self
        }
    }
    
    var mainWindowViewController: MainWindowController!
    
    var mainViewController: MainViewController! {
        didSet{
            mainViewController.windmill = self.windmill
            mainViewController.scheduler = self.windmill.scheduler
            self.windmill.delegate = mainViewController
        }
    }
    
    lazy var keychain: Keychain = Keychain.defaultKeychain()
    lazy var windmill: Windmill = Windmill.windmill(self.keychain)

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.mainWindowDidLoad(_:)), name: NSNotification.Name("mainWindowDidLoad"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.activityError(_:)), name: Process.Notifications.activityError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.windmillWillDeployProject(_:)), name: Windmill.Notifications.willDeployProject, object: nil)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        self.keychain.createUser(userIdentifier)
        self.windmill.start()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        
        if(!flag) {
            self.mainWindowViewController.window?.setIsVisible(true)
        }
        
        return true
    }
    
    func mainWindowDidLoad(_ aNotification: Notification) {
        let mainWindowViewController = aNotification.object as! MainWindowController
        self.mainWindowViewController = mainWindowViewController
        self.mainViewController = mainWindowViewController.contentViewController as! MainViewController
    }
    
    func mouseDown(_ theEvent: NSEvent)
    {
        guard let statusItem = self.statusItem else {
            return
        }
        
        DispatchQueue.main.async {
            statusItem.popUpMenu(statusItem.menu!)
        }
    }
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation
    {
        return .copy;
    }
    
    func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation
    {
        return .copy;
        
    }
    
    func draggingExited(_ sender: NSDraggingInfo!)
    {
    }
    
    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool
    {
        return true;
        
    }
    
    func performDragOperation(_ info: NSDraggingInfo) -> Bool {
        
        guard let folder = info.draggingPasteboard().firstFilename() else {
            return false
        }
        
        os_log("%{public}@", log: .default, type: .info, folder)
        
        do {
            let project = try Project.parse(fullPathOfLocalGitRepo: folder)
            
            return self.windmill.create(project)
        } catch let error as NSError {
            alert(error, window: self.mainWindowViewController.window!)
            return false
        }
    }
    
    func windmillWillDeployProject(_ aNotification: Notification) {
        statusItem.button?.startAnimation()
    }
    
    func activityError(_ aNotification: Notification) {
        statusItem.button?.stopAnimation()
    }
}
