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
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var debugAreaMenuItem: NSMenuItem!
    @IBOutlet weak var runMenuItem: NSMenuItem!
    @IBOutlet weak var cleanMenu: NSMenuItem!
    @IBOutlet weak var cleanProjectMenu: NSMenuItem!
    
    lazy var statusItem: NSStatusItem = { [unowned self] in
        
        let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
        statusItem.menu = self.menu
        statusItem.button?.image = #imageLiteral(resourceName: "statusItem")
        statusItem.button?.toolTip = NSLocalizedString("windmill.toolTip", comment: "")
        statusItem.button?.window?.registerForDraggedTypes([NSFilenamesPboardType])
        statusItem.button?.window?.delegate = self
        
        return statusItem
    }()

    @IBOutlet weak var activityMenuItem: NSMenuItem! {
        didSet{
            activityMenuItem.title = NSLocalizedString("windmill.ui.activityTextfield.idle", comment: "")
        }
    }

    var mainWindowViewController: MainWindowController!
    
    var mainViewController: MainViewController! {
        didSet{
            mainViewController.windmill = self.windmill
        }
    }
    
    lazy var keychain: Keychain = Keychain.defaultKeychain()
    lazy var windmill: Windmill = Windmill.windmill(self.keychain)

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.mainWindowDidLoad(_:)), name: NSNotification.Name("mainWindowDidLoad"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.activityDidLaunch(_:)), name: Process.Notifications.activityDidLaunch, object: nil)
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
        statusItem.button?.image = #imageLiteral(resourceName: "statusItem-active")
        self.cleanMenu.isEnabled = false
        self.cleanProjectMenu.isEnabled = false
    }
    
    func activityDidLaunch(_ aNotification: Notification) {
        let activityType = ActivityType(rawValue: aNotification.userInfo!["activity"] as! String)!

        self.activityMenuItem.title = activityType.description
    }

    func activityError(_ aNotification: Notification) {
        self.activityMenuItem.title = NSLocalizedString("windmill.ui.activityTextfield.stopped", comment: "")
        statusItem.button?.image = #imageLiteral(resourceName: "statusItem")
        self.cleanMenu.isEnabled = true
        self.cleanProjectMenu.isEnabled = true
    }
    
    @IBAction func run(_ sender: Any) {
        self.windmill = Windmill.windmill(self.keychain)
        self.mainViewController.windmill = self.windmill
        self.mainViewController.toggleDebugArea(debugAreaMenuItem)
        self.windmill.start()
    }
    
    @IBAction func cleanBuildFolder(_ sender: Any) {
        self.mainViewController.cleanBuildFolder()
    }
    
    @IBAction func cleanProjectFolder(_ sender: Any) {

        let alert = NSAlert()
        alert.addButton(withTitle: "Remove")
        alert.addButton(withTitle: "Cancel")
        alert.messageText = "Remove the checkout folder?"
        alert.informativeText = "This will perform a new checkout of the repository and `Run` again."
        alert.alertStyle = .warning
        alert.window.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)

        alert.beginSheetModal(for: self.mainWindowViewController.window!) { response in
            
            guard response == NSAlertFirstButtonReturn else {
                return
            }
            
            if self.mainViewController.cleanProjectFolder() {
                self.run(self.runMenuItem)
            }
        }
    }
}
