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


class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate
{
    static let logger : ConsoleLog = ConsoleLog()

    @IBOutlet weak var menu: NSMenu! {
        didSet{
            self.statusItem = NSStatusBar.systemStatusItem(self.menu, event:Event(
                action: "mouseDown:",
                target: self,
                mask: NSEventMask.LeftMouseDownMask
                ))
        }
    }
    
    var statusItem: NSStatusItem! {
        didSet{
            statusItem.toolTip = NSLocalizedString("applicationDidFinishLaunching.statusItem.toolTip", comment: "")
            
            let image = NSImage(named:"statusItem")!
            image.template = true
            statusItem.button?.image = image
            self.statusItem.button?.window?.registerForDraggedTypes([NSFilenamesPboardType])
            self.statusItem.button?.window?.delegate = self
        }
    }
    
    var mainViewController: MainViewController! {
        didSet{
            mainViewController.projectsViewController.windmill = self.windmill
            mainViewController.projectDetailViewController.scheduler = self.windmill.scheduler
        }
    }
    
    lazy var keychain: Keychain = Keychain.defaultKeychain()
    lazy var windmill: Windmill = Windmill.windmill(self.keychain)

    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("mainWindowDidLoad:"), name: "mainWindowDidLoad", object: nil)
    }
    
    func applicationDidFinishLaunching(notification: NSNotification)
    {
        self.keychain.createUser(userIdentifier)
        self.windmill.start()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
    }
    
    func mainWindowDidLoad(aNotification: NSNotification) {
        let mainWindowViewController = aNotification.object as! MainWindowController
        self.mainViewController = mainWindowViewController.contentViewController as! MainViewController
    }
    
    func mouseDown(theEvent: NSEvent)
    {
        let statusItem = self.statusItem
        dispatch_async(dispatch_get_main_queue()){
            statusItem.popUpStatusItemMenu(statusItem.menu!)
        }
    }
    
    func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation
    {
        print(__FUNCTION__);
        return .Copy;
    }
    
    func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation
    {
        return .Copy;
        
    }
    
    func draggingExited(sender: NSDraggingInfo!)
    {
        print(__FUNCTION__);
    }
    
    func prepareForDragOperation(sender: NSDraggingInfo) -> Bool
    {
        print(__FUNCTION__);
        return true;
        
    }
    
    func performDragOperation(info: NSDraggingInfo) -> Bool {
        return self.mainViewController.performDragOperation(info)
    }
}

