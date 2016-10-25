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
                action: #selector(AppDelegate.mouseDown(_:)),
                target: self,
                mask: NSEventMask.LeftMouseDown
                ))
        }
    }
    
    var statusItem: NSStatusItem! {
        didSet{
            statusItem.toolTip = NSLocalizedString("windmill.toolTip", comment: "")
            
            let image = NSImage(named:"statusItem")!
            image.template = true
            statusItem.button?.image = image
            self.statusItem.button?.window?.registerForDraggedTypes([NSFilenamesPboardType])
            self.statusItem.button?.window?.delegate = self
        }
    }
    
    var mainWindowViewController: MainWindowController!
    
    var mainViewController: MainViewController! {
        didSet{
            mainViewController.scheduler = self.windmill.scheduler
            self.windmill.delegate = mainViewController
        }
    }
    
    lazy var keychain: Keychain = Keychain.defaultKeychain()
    lazy var windmill: Windmill = Windmill.windmill(self.keychain)

    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.mainWindowDidLoad(_:)), name: "mainWindowDidLoad", object: nil)
    }
    
    func applicationDidFinishLaunching(notification: NSNotification)
    {
        self.keychain.createUser(userIdentifier)
        self.windmill.start()
    }
    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        
        if(!flag) {
            self.mainWindowViewController.window?.setIsVisible(true)
        }
        
        return true
    }
    
    func mainWindowDidLoad(aNotification: NSNotification) {
        let mainWindowViewController = aNotification.object as! MainWindowController
        self.mainWindowViewController = mainWindowViewController
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
        print(#function);
        return .Copy;
    }
    
    func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation
    {
        return .Copy;
        
    }
    
    func draggingExited(sender: NSDraggingInfo!)
    {
        print(#function);
    }
    
    func prepareForDragOperation(sender: NSDraggingInfo) -> Bool
    {
        print(#function);
        return true;
        
    }
    
    func performDragOperation(info: NSDraggingInfo) -> Bool {
        print(#function)
        
        guard let folder = info.draggingPasteboard().firstFilename() else {
            return false
        }
        
        AppDelegate.logger.log(.INFO, folder)
        
        do {
            let project = try Windmill.parse(fullPathOfLocalGitRepo: folder)
            
            return self.windmill.create(project)
        } catch let error as NSError {
            alert(error, window: self.mainWindowViewController.window!)
            return false
        }
    }
}

