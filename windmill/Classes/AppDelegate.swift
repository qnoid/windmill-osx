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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSUserNotificationCenterDelegate
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

    var isSidePanelCollapsedObserver: NSKeyValueObservation?
    var isBottomPanelCollapsedObserver: NSKeyValueObservation?

    var mainWindowViewController: MainWindowController? {
        didSet {
            guard let mainWindowViewController = mainWindowViewController else {
                return
            }
            mainViewController = mainWindowViewController.mainViewController
            
            self.isSidePanelCollapsedObserver = mainWindowViewController.sidePanelSplitViewController?.onCollapsed { [weak self = self](splitviewitem, change) in
                if let isCollapsed = change.newValue {
                    self?.sidePanelMenuItem.title = isCollapsed ? NSLocalizedString("windmill.ui.toolbar.view.showSidePanel", comment: ""): NSLocalizedString("windmill.ui.toolbar.view.hideSidePanel", comment: "")
                }
            }

            self.isBottomPanelCollapsedObserver = mainWindowViewController.bottomPanelSplitViewController?.onCollapsed { [weak self = self](splitviewitem, change) in
                if let isCollapsed = change.newValue {
                    self?.debugAreaMenuItem.title = isCollapsed ? NSLocalizedString("windmill.ui.toolbar.view.showDebugArea", comment: "") : NSLocalizedString("windmill.ui.toolbar.view.hideDebugArea", comment: "")
                }
            }
        }
    }
    
    var mainViewController: MainViewController?
    
    lazy var keychain: Keychain = Keychain.defaultKeychain()
    
    var projects : Array<Project> = InputStream.inputStreamOnProjects().read() {
        didSet {
            OutputStream.outputStreamOnProjects().write(self.projects)
        }
    }

    deinit {
        isSidePanelCollapsedObserver?.invalidate()
        isBottomPanelCollapsedObserver?.invalidate()
    }

    private func add(_ project: Project) -> Bool
    {
        guard !self.projects.contains(project) else {
            return false
        }
        
        self.projects = []
        self.projects.append(project)
        return true
    }
    
    private func start(windmill: Windmill, sequence: Sequence) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(activityDidLaunch(_:)), name: Windmill.Notifications.activityDidLaunch, object: windmill)
        NotificationCenter.default.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.activityError, object: windmill)
        NotificationCenter.default.addObserver(self, selector: #selector(willStartProject(_:)), name: Windmill.Notifications.willStartProject, object: windmill)
        NotificationCenter.default.addObserver(self, selector: #selector(windmillMonitoringProject(_:)), name: Windmill.Notifications.willMonitorProject, object: windmill)
        
        windmill.run(sequence: sequence)
    }
    
    private func makeKeyAndOrderFront(mainWindowController: MainWindowController) {
        self.mainWindowViewController = mainWindowController
        self.mainWindowViewController?.window?.makeKeyAndOrderFront(self)
    }
    
    private func makeMainWindowKeyAndOrderFront(windmill: Windmill, sequence: Sequence, project: Project) {
        guard let mainWindowController = MainWindowController.make(windmill: windmill), let window = mainWindowController.window else {
            return
        }
        
        window.title = project.name
        self.makeKeyAndOrderFront(mainWindowController: mainWindowController)
        self.start(windmill: windmill, sequence: sequence)
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        self.mainWindowViewController?.window?.setIsVisible(false)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        #if DEBUG
        self.keychain.createUser(UUID().uuidString)
        #endif

        let hasProjects = projects.count > 0

        if !hasProjects {
            let notification = NSUserNotification()
            notification.title = "Getting started."
            notification.informativeText = NSLocalizedString("notification.gettingstarted", comment: "")
            notification.contentImage = #imageLiteral(resourceName: "statusItem")
            
            notification.actionButtonTitle = NSLocalizedString("notification.gettingstarted.action", comment: "")
            
            let center = NSUserNotificationCenter.default
            center.delegate = self
            center.deliver(notification)
        }

        if let project = projects.last {
            let pipeline = Windmill.make(project: project)
            makeMainWindowKeyAndOrderFront(windmill: pipeline.windmill, sequence: pipeline.sequence, project: project)
        }
        
        mainWindowViewController?.window?.setIsVisible(hasProjects)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        
        if(!flag) {
            self.mainWindowViewController?.window?.setIsVisible(true)
        }
        
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        let gettingStartedWindowController = GettingStartedWindowController.make()
        gettingStartedWindowController.showWindow(self)
        gettingStartedWindowController.window?.orderFront(self)
    }
    
    
    @objc func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation
    {
        return .link;
    }
    
    @objc func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation
    {
        return .link;
        
    }
    
    @objc func draggingExited(_ sender: NSDraggingInfo!)
    {
    }
    
    @objc func prepareForDragOperation(_ info: NSDraggingInfo) -> Bool {
        
        guard let folder = info.draggingPasteboard().firstFilename() else {
            return false
        }

        os_log("%{public}@", log: .default, type: .info, folder)

        do {
            let commit = try Repository.parse(fullPathOfLocalGitRepo: folder)
            let project = Project.make(repository: commit.repository)

            return self.add(project)
        } catch let error as NSError {
            guard let window = self.mainWindowViewController?.window else {
                return false
            }
            alert(error, window: window)
            return false
        }
    }
    
    @objc func performDragOperation(_ info: NSDraggingInfo) -> Bool {

        guard let project = projects.last else {
            os_log("Did you add the project in the array when `prepareForDragOperation` was called?", log: .default, type: .error)
            return false
        }
        
        let pipeline = Windmill.make(project: project)
        makeMainWindowKeyAndOrderFront(windmill: pipeline.windmill, sequence: pipeline.sequence, project: project)

        return true
    }
    
    /**
     `For this method to be invoked, the previous performDragOperation(_:) must have returned true.`
     
    */
    @objc func concludeDragOperation(_ sender: NSDraggingInfo?)
    {
        self.mainWindowViewController?.window?.orderFrontRegardless()
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(openDocument(_:)) {
            return self.mainWindowViewController?.window != nil
        }
        
        return true
    }
    
    @IBAction func openAcknowledgements(_ sender: Any) {
        guard let url = Bundle(for: GettingStartedWindowController.self).url(forResource: "Acknowledgements", withExtension: "rtf") else {
            return
        }
        
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func openDocument(_ sender: Any) {
        guard let window = self.mainWindowViewController?.window else {
            return
        }
        
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false

        openPanel.beginSheetModal(for: window)  { response in
            
            guard response == NSApplication.ModalResponse.OK else {
                return
            }

            do{
                let url = openPanel.urls[0]
                let commit = try Repository.parse(localGitRepoURL: url)
                let project = Project.make(repository: commit.repository)
            
                if self.add(project) {
                    let pipeline = Windmill.make(project: project)
                    self.makeMainWindowKeyAndOrderFront(windmill: pipeline.windmill, sequence: pipeline.sequence, project: project)
                }
            } catch let error as NSError {
                alert(error, window: window)
            }
        }
    }
    
    @objc func willStartProject(_ aNotification: Notification) {
        self.statusItem.button?.image = #imageLiteral(resourceName: "statusItem-active")
        self.statusItem.button?.toolTip = ""
        self.cleanMenu.isEnabled = false
        self.cleanProjectMenu.isEnabled = false
    }
    
    @objc func windmillMonitoringProject(_ aNotification: Notification) {
        self.activityMenuItem.toolTip = NSLocalizedString("windmill.toolTip.active.monitor", comment: "")
        self.activityMenuItem.title = "monitoring"
    }
    
    @objc func activityDidLaunch(_ aNotification: Notification) {
        
        guard let activity = aNotification.userInfo?["activity"] as? ActivityType else {
            return
        }

        self.activityMenuItem.toolTip = NSLocalizedString("windmill.toolTip.active.\(activity.rawValue)", comment: "")
        self.activityMenuItem.title = activity.description
    }

    @objc func activityError(_ aNotification: Notification) {
        if let error = aNotification.userInfo?["error"] as? NSError {
            statusItem.button?.toolTip = error.localizedDescription
        }

        self.statusItem.button?.image = #imageLiteral(resourceName: "statusItem")
        self.activityMenuItem.toolTip = ""
        self.activityMenuItem.title = NSLocalizedString("windmill.ui.activityTextfield.stopped", comment: "")
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
        guard let project = projects.last else {
            os_log("Did you add the last project dragged and dropped in `prepareForDragOperation`?", log: .default, type: .error)
            return
        }
        
        let pipeline = Windmill.make(project: project)
        self.mainWindowViewController?.windmill = pipeline.windmill
        self.toggleDebugArea(sender: sender, isCollapsed: true)
        
        self.start(windmill: pipeline.windmill, sequence: pipeline.sequence)
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
