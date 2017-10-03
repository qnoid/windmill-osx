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
        didSet {
            statusItem.menu = self.menu
        }
    }
    @IBOutlet weak var debugAreaMenuItem: NSMenuItem!
    @IBOutlet weak var sidePanelMenuItem: NSMenuItem!
    @IBOutlet weak var runMenuItem: NSMenuItem!
    @IBOutlet weak var cleanMenu: NSMenuItem!
    @IBOutlet weak var cleanProjectMenu: NSMenuItem!
    
    lazy var statusItem: NSStatusItem = { [unowned self] in
        
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = #imageLiteral(resourceName: "statusItem")
        statusItem.button?.toolTip = NSLocalizedString("windmill.toolTip", comment: "")
        statusItem.button?.window?.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
        statusItem.button?.window?.delegate = self
        
        return statusItem
    }()

    @IBOutlet weak var activityMenuItem: NSMenuItem! {
        didSet{
            activityMenuItem.title = NSLocalizedString("windmill.ui.activityTextfield.idle", comment: "")
        }
    }

    var mainWindowViewController: MainWindowController? {
        didSet {
            guard let mainWindowViewController = mainWindowViewController else {
                return
            }
        
            mainWindowViewController.sidePanelMenuItem = sidePanelMenuItem
            mainWindowViewController.debugAreaMenuItem = debugAreaMenuItem
            mainViewController = mainWindowViewController.mainViewController
            windmill.delegate = mainWindowViewController.bottomPanelSplitViewController?.consoleViewController
        }
    }
    
    var mainViewController: MainViewController?
    
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
            self.mainWindowViewController?.window?.setIsVisible(true)
        }
        
        return true
    }
    
    @objc func mainWindowDidLoad(_ aNotification: Notification) {
        guard let mainWindowViewController = aNotification.object as? MainWindowController else {
            os_log("%{public}@", log:.default, type: .error, "`MainWindowController` did not send the `mainWindowDidLoad` notification. Did you set the `object` property?")
            return
        }
        
        self.mainWindowViewController = mainWindowViewController
    }
    
    @objc func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation
    {
        return .copy;
    }
    
    @objc func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation
    {
        return .copy;
        
    }
    
    @objc func draggingExited(_ sender: NSDraggingInfo!)
    {
    }
    
    @objc func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool
    {
        return true;
        
    }
    
    @objc func performDragOperation(_ info: NSDraggingInfo) -> Bool {
        
        guard let folder = info.draggingPasteboard().firstFilename() else {
            return false
        }
        
        os_log("%{public}@", log: .default, type: .info, folder)
        
        do {
            let commit = try Repository.parse(fullPathOfLocalGitRepo: folder)
            let project = Project.make(repository: commit.repository)
            
            return self.windmill.create(project)
        } catch let error as NSError {
            guard let window = self.mainWindowViewController?.window else {
                return false
            }
            alert(error, window: window)
            return false
        }
    }
    
    @objc func windmillWillDeployProject(_ aNotification: Notification) {
        statusItem.button?.image = #imageLiteral(resourceName: "statusItem-active")
        self.cleanMenu.isEnabled = false
        self.cleanProjectMenu.isEnabled = false
    }
    
    @objc func activityDidLaunch(_ aNotification: Notification) {
        let activityType = ActivityType(rawValue: aNotification.userInfo!["activity"] as! String)!

        self.activityMenuItem.title = activityType.description
    }

    @objc func activityError(_ aNotification: Notification) {
        self.activityMenuItem.title = NSLocalizedString("windmill.ui.activityTextfield.stopped", comment: "")
        statusItem.button?.image = #imageLiteral(resourceName: "statusItem")
        self.cleanMenu.isEnabled = true
        self.cleanProjectMenu.isEnabled = true
        self.toggleDebugArea(isCollapsed: false)
    }

    func toggleDebugArea(sender: Any? = nil, isCollapsed: Bool? = nil) {
        self.mainWindowViewController?.toggleDebugArea(isCollapsed: isCollapsed)
    }
    
    @IBAction func toggleDebugArea(_ sender: Any) {
        self.toggleDebugArea(sender: sender)
    }
    
    func toggleSidePanel(sender: Any? = nil, isCollapsed: Bool? = nil) {
        self.mainWindowViewController?.toggleSidePanel(isCollapsed: isCollapsed)
    }

    @IBAction func toggleSidePanel(_ sender: Any) {
        self.toggleSidePanel(sender: sender)
    }

    @IBAction func performSegmentedControlAction(_ segmentedControl: NSSegmentedControl) {
        switch segmentedControl.selectedSegment {
        case 0:
            self.toggleDebugArea(sender: segmentedControl)
        case 1:
            self.toggleSidePanel(sender: segmentedControl)
        default:
            os_log("Index of selected segment for NSSegmentedControl does not have a corresponding action associated.", log: .default, type: .debug)
        }
    }

    @IBAction func run(_ sender: Any) {
        let windmill = Windmill.windmill(self.keychain)
        windmill.delegate = self.windmill.delegate
        self.windmill = windmill
        self.toggleDebugArea(sender: sender, isCollapsed: true)
        self.windmill.start()
    }
    
    @IBAction func cleanBuildFolder(_ sender: Any) {
        self.mainViewController?.cleanBuildFolder()
    }
    
    @IBAction func cleanProjectFolder(_ sender: Any) {

        let alert = NSAlert()
        alert.addButton(withTitle: "Remove")
        alert.addButton(withTitle: "Cancel")
        alert.messageText = "Remove the checkout folder?"
        alert.informativeText = "This will perform a new checkout of the repository and `Run` again."
        alert.alertStyle = .warning
        alert.window.appearance = NSAppearance(named: .vibrantDark)

        guard let window = self.mainWindowViewController?.window else {
            return
        }
        
        alert.beginSheetModal(for: window) { response in
            
            guard response == .alertFirstButtonReturn else {
                return
            }
            
            if self.mainViewController?.cleanProjectFolder() == true {
                self.run(self.runMenuItem)
            }
        }
    }
}
