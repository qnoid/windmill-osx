//
//  AppDelegate.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 07/06/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import AppKit
import Foundation
import os

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSUserNotificationCenterDelegate, MainWindowControllerDelegate
{
    @IBOutlet weak var menu: NSMenu! {
        didSet {
            statusItem.menu = self.menu
        }
    }
    @IBOutlet weak var launchMenuItem: NSMenuItem! {
        didSet{
            self.isLaunchMenuItemEnabledObserver = launchMenuItem.observe(\.isEnabled, options: [.initial, .new]) { (menuItem, change) in
                if let isEnabled = change.newValue {
                    if isEnabled {
                        menuItem.toolTip = NSLocalizedString("windmill.launchsimulator.button.enabled.toolTip", comment: "")
                    } else {
                        menuItem.toolTip = NSLocalizedString("windmill.launchsimulator.button.disabled.toolTip", comment: "")
                    }
                }
            }
            self.launchMenuItem.isEnabled = false
        }
    }
    
    @IBOutlet weak var recordVideoMenuItem: NSMenuItem! {
        didSet {
            self.isRecordVideoMenuItemEnabledObserver = recordVideoMenuItem.observe(\.isEnabled, options: [.initial, .new]) { (menuItem, change) in
                if let isEnabled = change.newValue {
                    if isEnabled {
                        menuItem.toolTip = NSLocalizedString("windmill.recordVideo.button.enabled.toolTip", comment: "")
                    } else {
                        menuItem.toolTip = NSLocalizedString("windmill.recordVideo.button.disabled.toolTip", comment: "")
                    }
                }
            }
            self.recordVideoMenuItem.isEnabled = false
        }
    }

    lazy var statusItem: NSStatusItem = { [unowned self] in
        
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(imageLiteralResourceName: "statusItem")
        statusItem.button?.toolTip = NSLocalizedString("windmill.toolTip", comment: "")
        statusItem.button?.window?.registerForDraggedTypes([.fileURL])
        statusItem.button?.window?.delegate = self
        
        return statusItem
    }()

    var isLaunchMenuItemEnabledObserver: NSKeyValueObservation?
    var isRecordVideoMenuItemEnabledObserver: NSKeyValueObservation?

    var windows: [NSWindow:MainWindowController] = [:]
    
    lazy var keychain: Keychain = Keychain.default
    
    deinit {
        isLaunchMenuItemEnabledObserver?.invalidate()
        isRecordVideoMenuItemEnabledObserver?.invalidate()
    }
    
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            self.windows[window]?.windowWillClose(notification)
            self.windows[window] = nil
        }
        
        if self.windows.isEmpty {
            self.statusItem.button?.image = NSImage(imageLiteralResourceName: "statusItem")
            self.statusItem.button?.toolTip = NSLocalizedString("windmill.toolTip", comment: "")
        }
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        guard let window = notification.object as? NSWindow, let mainWindowController = self.windows[window] else {
            return
        }
        
        let sidePanelMenuItem = window.menu?.item(withTitle: "View")?.submenu?.item(withTitle: "Side Panel")?.submenu?.item(withTag: 0)
        sidePanelMenuItem?.title = mainWindowController.sidePanelSplitViewController?.sideViewSplitViewItem?.isCollapsed ?? false ? NSLocalizedString("windmill.ui.toolbar.view.showSidePanel", comment: ""): NSLocalizedString("windmill.ui.toolbar.view.hideSidePanel", comment: "")
        let debugAreaMenuItem = window.menu?.item(withTitle: "View")?.submenu?.item(withTitle: "Debug Area")?.submenu?.item(withTag: 0)
        debugAreaMenuItem?.title = mainWindowController.bottomPanelSplitViewController?.bottomViewSplitViewItem?.isCollapsed ?? false ? NSLocalizedString("windmill.ui.toolbar.view.showDebugArea", comment: "") : NSLocalizedString("windmill.ui.toolbar.view.hideDebugArea", comment: "")
    }
    
    private func run(windmill: Windmill, skipCheckout: Bool = false) {

        NotificationCenter.default.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.didError, object: windmill)

        windmill.run(skipCheckout: skipCheckout)
    }
    
    private func makeKeyAndOrderFront(mainWindowController: MainWindowController) {
        if let window = mainWindowController.window {
            self.windows[window] = mainWindowController
        }

        mainWindowController.window?.delegate = self
        mainWindowController.window?.menu = NSApplication.shared.mainMenu
        mainWindowController.delegate = self
        mainWindowController.window?.makeKeyAndOrderFront(self)
        self.statusItem.button?.image = NSImage(imageLiteralResourceName: "statusItem-active")
        self.statusItem.button?.toolTip = NSLocalizedString("windmill.toolTip.active", comment: "")
    }
    
    private func makeMainWindowKeyAndOrderFront(windmill: Windmill) {
        if let keyWindowController = NSApplication.shared.keyWindow?.windowController as? MainWindowController {
            keyWindowController.windmill = windmill
            self.makeKeyAndOrderFront(mainWindowController: keyWindowController)
        } else if let mainWindowController = MainWindowController.make(windmill: windmill) {
            self.makeKeyAndOrderFront(mainWindowController: mainWindowController)
        }
        
        run(windmill: windmill)
    }

    private func makeMainTabbedWindow(windmill: Windmill) {
        switch NSApplication.shared.keyWindow?.windowController as? MainWindowController {
        case .none:
            makeMainWindowKeyAndOrderFront(windmill: windmill)
        case .some(let keyWindowController):
            guard let mainWindowController = MainWindowController.make(windmill: windmill), let window = mainWindowController.window else {
                return
            }
            window.delegate = self
            window.menu = NSApplication.shared.mainMenu
            mainWindowController.delegate = self
            keyWindowController.addTabbedWindow(mainWindowController: mainWindowController)
            self.windows[window] = mainWindowController
            run(windmill: windmill)
        }
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        guard let project = self.addProject(url: URL(fileURLWithPath: filename)) else {
            os_log("Have you saved the configuration for that project?", log: .default, type: .debug)
            return false
        }
        
        let windmill = Windmill.make(project: project)
        Windmill.Configuration.shared.write(windmill.configuration)
        self.makeMainTabbedWindow(windmill: windmill)
        
        return true
    }
    
    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
        SubscriptionManager.shared.subscriptionNotification(userInfo: userInfo)
    }
    
    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        os_log("%{public}@", log: .default, type: .debug, #function)
    }
    
    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        os_log("%{public}@", log: .default, type: .debug, #function)
    }
    
    func migrate() {
        let url = Directory.Windmill.ApplicationSupportDirectory().file("projects.json").URL

        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            let projects = try decoder.decode([Project].self, from: data)
            
            if let project = projects.first {
                let configuration = Windmill.Configuration.make(project: project)
                Windmill.Configuration.shared.write(configuration)
            }
            
            try FileManager.default.removeItem(at: url)
        } catch {
            os_log("%{public}@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        self.migrate()
        
        NSApplication.shared.keyWindow?.setIsVisible(false)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        SubscriptionManager.shared.fetchSubscription()
        SubscriptionManager.shared.registerForSubscriptionNotifications()
        
        #if DEBUG
        let isUnitTesting = ProcessInfo.processInfo.arguments.contains("-UNITTEST")
        guard !isUnitTesting else {
            return
        }
        #endif
        
        let anyConfigurations = Windmill.Configuration.shared.count > 0

        if !anyConfigurations {
            let notification = NSUserNotification()
            notification.title = "Getting started."
            notification.informativeText = NSLocalizedString("notification.gettingstarted", comment: "")
            
            
            notification.actionButtonTitle = NSLocalizedString("notification.gettingstarted.action", comment: "")
            
            let center = NSUserNotificationCenter.default
            center.delegate = self
            center.deliver(notification)
        } else if let configuration = Windmill.Configuration.shared.first {
            let windmill = Windmill.make(configuration: configuration)
            makeMainWindowKeyAndOrderFront(windmill: windmill)
        }
        
        NSApplication.shared.keyWindow?.setIsVisible(anyConfigurations)
        
        Windmill.Configuration.shared.dropFirst().forEach { configuration in
            let windmill = Windmill.make(configuration: configuration)
            makeMainTabbedWindow(windmill: windmill)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        
        if(!flag) {
            NSApplication.shared.keyWindow?.setIsVisible(true)
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
        return .link
    }
    
    @objc func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation
    {
        return .link
        
    }
    
    @objc func draggingExited(_ sender: NSDraggingInfo!)
    {
    }
    
    func addProject(url: URL) -> Project? {
        return self.add(url: url, branch: "master")?.project
    }

    func add(url: URL, branch: String? = nil) -> (project: Project, branch: String)? {
        let lastPathComponent = url.lastPathComponent
        let isWorkspace = lastPathComponent.hasSuffix(".xcworkspace")
        let isProject = lastPathComponent.hasSuffix(".xcodeproj")
        
        guard isWorkspace || isProject  else {
            return nil
        }

        do {
            
            let name = url.deletingPathExtension().lastPathComponent
            let commit = try Repository.parse(localGitRepoURL: url)
            let project = Project.make(isWorkspace: isWorkspace, name: name, repository: commit.repository)
            
            return Windmill.Configuration.shared.contains(project, branch: branch ?? commit.branch) == true ? nil : (project, branch ?? commit.branch)
        } catch let error as NSError {
            let alert = Alerts.make(error)
            if let window = NSApplication.shared.keyWindow {
                alert.beginSheetModal(for: window, completionHandler: nil)
            } else {
                alert.runModal()
            }
            return nil
        }
    }
    
    @objc func prepareForDragOperation(_ info: NSDraggingInfo) -> Bool {
        
        guard let url = info.draggingPasteboard.fileURL() else {
            return false
        }

        os_log("%{public}@", log: .default, type: .debug, url.path)

        if let project = self.addProject(url: url) {
            let configuration = Windmill.Configuration.make(project: project)
            Windmill.Configuration.shared.write(configuration)
            return true
        }
        
        return false
    }
    
    @objc func performDragOperation(_ info: NSDraggingInfo) -> Bool {

        guard let configuration = Windmill.Configuration.shared.reversed().first else {
            os_log("Did you add the configuration when `prepareForDragOperation` was called?", log: .default, type: .error)
            return false
        }
        
        let windmill = Windmill.make(configuration: configuration)
        makeMainTabbedWindow(windmill: windmill)

        return true
    }
    
    /**
     `For this method to be invoked, the previous performDragOperation(_:) must have returned true.`
     
    */
    @objc func concludeDragOperation(_ sender: NSDraggingInfo?)
    {
        NSApplication.shared.keyWindow?.orderFrontRegardless()
    }
    
    @IBAction func openAcknowledgements(_ sender: Any) {
        guard let url = Bundle(for: GettingStartedWindowController.self).url(forResource: "Acknowledgements", withExtension: "rtf") else {
            return
        }
        
        NSWorkspace.shared.open(url)
    }

    @IBAction func openPrivacy(_ sender: Any) {
        guard let url = URL(string: "https://windmill.io/privacy/") else {
            return
        }
        
        NSWorkspace.shared.open(url)
    }

    @IBAction func openDocument(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["com.apple.dt.document.workspace","com.apple.xcode.project"]

        openPanel.begin { response in
            
            guard response == NSApplication.ModalResponse.OK else {
                return
            }

            guard let url = openPanel.urls.first else {
                return
            }
            
            if let project = self.addProject(url: url) {
                let windmill = Windmill.make(project: project)
                Windmill.Configuration.shared.write(windmill.configuration)
                self.makeMainTabbedWindow(windmill: windmill)
            }
        }
    }
    
    @IBAction func openProjectAtBranch(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["com.apple.dt.document.workspace","com.apple.xcode.project"]
        
        openPanel.begin { response in
            
            guard response == NSApplication.ModalResponse.OK else {
                return
            }
            
            guard let url = openPanel.urls.first else {
                return
            }
            
            if let add: (project: Project, branch: String) = self.add(url: url) {
                let configuration = Windmill.Configuration.make(project: add.project, branch: add.branch, activities: [.checkout, .build, .test])
                let windmill = Windmill.make(configuration: configuration)
                Windmill.Configuration.shared.write(configuration)
                self.makeMainTabbedWindow(windmill: windmill)
            }
        }
    }
    
    @objc func activityError(_ aNotification: Notification) {
        
        NSApplication.shared.requestUserAttention(.criticalRequest)
    }
    
    func sidePanelSplitViewController(mainWindowController: MainWindowController, isCollapsed: Bool) {
        let sidePanelMenuItem = mainWindowController.window?.menu?.item(withTitle: "View")?.submenu?.item(withTitle: "Side Panel")?.submenu?.item(withTag: 0)
        sidePanelMenuItem?.title = isCollapsed ? NSLocalizedString("windmill.ui.toolbar.view.showSidePanel", comment: ""): NSLocalizedString("windmill.ui.toolbar.view.hideSidePanel", comment: "")
    }
    
    func bottomPanelSplitViewController(mainWindowController: MainWindowController, isCollapsed: Bool) {
        let debugAreaMenuItem = mainWindowController.window?.menu?.item(withTitle: "View")?.submenu?.item(withTitle: "Debug Area")?.submenu?.item(withTag: 0)
        debugAreaMenuItem?.title = isCollapsed ? NSLocalizedString("windmill.ui.toolbar.view.showDebugArea", comment: "") : NSLocalizedString("windmill.ui.toolbar.view.hideDebugArea", comment: "")
    }
    
    @IBAction func openFrequentlyAskedQuestions(_ sender: Any) {
        let faqURL = URL(string: "https://windmill.io/faq/")!
        NSWorkspace.shared.open(faqURL)
    }
    
    @IBAction func openVersionHistory(_ sender: Any) {
        let changelogURL = URL(string: "https://windmill.io/changelog/")!
        NSWorkspace.shared.open(changelogURL)
    }    
}
