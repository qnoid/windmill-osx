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

    @IBOutlet weak var menu: NSMenu!
    
    weak var window: NSWindow!
    var statusItem: NSStatusItem! {
        didSet{
            self.statusItem.toolTip = NSLocalizedString("applicationDidFinishLaunching.statusItem.toolTip", comment: "")
            
            let image = NSImage(named:"windmill")!
            image.setTemplate(true)
            self.statusItem.button?.image = image
            self.statusItem.button?.window?.registerForDraggedTypes([NSFilenamesPboardType])
            self.statusItem.button?.window?.delegate = self
        }
    }
    
    var mainWindowController: MainWindowController!
    
    let keychain: Keychain = Keychain.defaultKeychain()
    let windmill: Windmill
    
    override required init()
    {
        self.windmill = Windmill(keychain: self.keychain)
        super.init()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        self.statusItem = NSStatusBar.systemStatusItem(self.menu, event:Event(
            action: "mouseDown:",
            target: self,
            mask: NSEventMask.LeftMouseDownMask
            ))
        
        self.keychain.createUser(userIdentifier)
        self.mainWindowController = MainWindowController.mainWindowController(self.windmill)
        
        self.window = self.mainWindowController.window
        self.window.makeKeyAndOrderFront(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
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
        println(__FUNCTION__);
        return .Copy;
    }
    
    func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation
    {
        return .Copy;
        
    }
    
    func draggingExited(sender: NSDraggingInfo!)
    {
        println(__FUNCTION__);
    }
    
    func prepareForDragOperation(sender: NSDraggingInfo) -> Bool
    {
        println(__FUNCTION__);
        return true;
        
    }
    
    func performDragOperation(info: NSDraggingInfo) -> Bool
    {
        println(__FUNCTION__);

        if let folder = info.draggingPasteboard().firstFilename()
        {
            AppDelegate.logger.log(.INFO, folder)
            self.windmill.add(folder)
            
            return true
        }
        
        return false
    }
}

