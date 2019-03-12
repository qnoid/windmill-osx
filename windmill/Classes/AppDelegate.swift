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
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSUserNotificationCenterDelegate, NSMenuItemValidation, MainWindowControllerDelegate
{
    @IBOutlet weak var menu: NSMenu! {
        didSet {
            statusItem.menu = self.menu
        }
    }
    @IBOutlet weak var debugAreaMenuItem: NSMenuItem!
    @IBOutlet weak var sidePanelMenuItem: NSMenuItem!

    @IBOutlet var projectTitlebarAccessoryViewController: ProjectTitlebarAccessoryViewController!
    
    var canCleanDerivedData = false
    var canRemoveCheckoutFolder = false

    lazy var statusItem: NSStatusItem = { [unowned self] in
        
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = #imageLiteral(resourceName: "statusItem")
        statusItem.button?.toolTip = NSLocalizedString("windmill.toolTip", comment: "")
        statusItem.button?.window?.registerForDraggedTypes([.fileURL])
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

    var mainWindowController: MainWindowController? {
        
        didSet {
            guard let mainWindowViewController = mainWindowController else {
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
    
    var errorSummariesWindowController: ErrorSummariesWindowController?
    var testFailureSummariesWindowController: TestFailureSummariesWindowController?
    var mainViewController: MainViewController?
    
    var testSummariesWindowController: TestSummariesWindowController?
    var commit: Repository.Commit?
    
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

    @discardableResult private func add(_ project: Project) -> Bool
    {
        guard !self.projects.contains(project) else {
            return false
        }
        
        self.projects = []
        self.projects.append(project)
        return true
    }
    
    private func start(windmill: Windmill, project: Project, skipCheckout: Bool = false) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(activityDidLaunch(_:)), name: Windmill.Notifications.activityDidLaunch, object: windmill)
        NotificationCenter.default.addObserver(self, selector: #selector(didCheckoutProject(_:)), name: Windmill.Notifications.didCheckoutProject, object: windmill)
        NotificationCenter.default.addObserver(self, selector: #selector(didTestProject(_:)), name: Windmill.Notifications.didTestProject, object: windmill)
        NotificationCenter.default.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.didError, object: windmill)
        NotificationCenter.default.addObserver(self, selector: #selector(willStartProject(_:)), name: Windmill.Notifications.willStartProject, object: windmill)
        NotificationCenter.default.addObserver(self, selector: #selector(willMonitorProject(_:)), name: Windmill.Notifications.willMonitorProject, object: windmill)
        
        windmill.run(project, skipCheckout: skipCheckout)
    }
    
    private func makeKeyAndOrderFront(mainWindowController: MainWindowController) {
        self.mainWindowController = mainWindowController
        self.mainWindowController?.delegate = self
        self.mainWindowController?.window?.makeKeyAndOrderFront(self)
    }
    
    private func makeMainWindowKeyAndOrderFront(windmill: Windmill, project: Project) {
        if let mainWindowController = self.mainWindowController {
            mainWindowController.windmill = windmill
            mainWindowController.project = project
            self.makeKeyAndOrderFront(mainWindowController: mainWindowController)
        } else if let mainWindowController = MainWindowController.make(windmill: windmill, project: project, projectTitlebarAccessoryViewController: projectTitlebarAccessoryViewController) {
            self.makeKeyAndOrderFront(mainWindowController: mainWindowController)
        }
        
        self.start(windmill: windmill, project: project)
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        guard let project = self.add(url: URL(fileURLWithPath: filename)) else {
            os_log("Did you add the project in the array?", log: .default, type: .error)
            return false
        }
        
        let windmill = Windmill.make(project: project)
        self.makeMainWindowKeyAndOrderFront(windmill: windmill, project: project)
        
        return true
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        self.mainWindowController?.window?.setIsVisible(false)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        #if DEBUG
        let isUnitTesting = ProcessInfo.processInfo.arguments.contains("-UNITTEST")
        guard !isUnitTesting else {
            return
        }
        #endif
        
        let hasProjects = projects.count > 0

        if !hasProjects {
            let notification = NSUserNotification()
            notification.title = "Getting started."
            notification.informativeText = NSLocalizedString("notification.gettingstarted", comment: "")
            
            
            notification.actionButtonTitle = NSLocalizedString("notification.gettingstarted.action", comment: "")
            
            let center = NSUserNotificationCenter.default
            center.delegate = self
            center.deliver(notification)
        }

        if let project = projects.last {
            let windmill = Windmill.make(project: project)
            makeMainWindowKeyAndOrderFront(windmill: windmill, project: project)
        }
        
        mainWindowController?.window?.setIsVisible(hasProjects)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        
        if(!flag) {
            self.mainWindowController?.window?.setIsVisible(true)
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
    
    
    func add(url: URL) -> Project? {
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
            
            return self.add(project) == true ? project : nil
        } catch let error as NSError {
            guard let window = self.mainWindowController?.window else {
                return nil
            }
            alert(error, window: window)
            return nil
        }
    }
    
    @objc func prepareForDragOperation(_ info: NSDraggingInfo) -> Bool {
        
        guard let url = info.draggingPasteboard.fileURL() else {
            return false
        }

        os_log("%{public}@", log: .default, type: .debug, url.path)

        return self.add(url: url) == nil ? false : true
    }
    
    @objc func performDragOperation(_ info: NSDraggingInfo) -> Bool {

        guard let project = projects.last else {
            os_log("Did you add the project in the array when `prepareForDragOperation` was called?", log: .default, type: .error)
            return false
        }
        
        let windmill = Windmill.make(project: project)
        makeMainWindowKeyAndOrderFront(windmill: windmill, project: project)

        return true
    }
    
    /**
     `For this method to be invoked, the previous performDragOperation(_:) must have returned true.`
     
    */
    @objc func concludeDragOperation(_ sender: NSDraggingInfo?)
    {
        self.mainWindowController?.window?.orderFrontRegardless()
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(run(_:)) {
            return projects.last != nil
        } else if menuItem.action == #selector(runSkipCheckout(_:)), let windmill = mainWindowController?.windmill {
            return windmill.isRepositoryDirectoryPresent()
        } else if menuItem.action == #selector(showProjectFolder(_:)), let windmill = mainViewController?.windmill {
            return windmill.isRepositoryDirectoryPresent()
        } else if menuItem.action == #selector(jumpToNextIssue(_:)) || menuItem.action == #selector(jumpToPreviousIssue(_:)) {
            
            let errorSummaries = errorSummariesWindowController?.errorSummariesViewController?.errorSummaries
            let testFailureSummaries = testFailureSummariesWindowController?.testFailureSummariesViewController?.testFailureSummaries
            
            switch (errorSummaries?.count, testFailureSummaries?.count) {
            case (let errorSummaries?, _) where errorSummaries > 0:
            return true
            case (_, let testFailureSummaries?) where testFailureSummaries > 0:
                return true
            default:
                return false
            }
            
        } else if menuItem.action == #selector(cleanDerivedData(_:)) {
            return self.canCleanDerivedData
        } else if menuItem.action == #selector(cleanProjectFolder(_:)) {
            return self.canRemoveCheckoutFolder
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
            
            guard let project = self.add(url: url) else {
                os_log("Did you add the project in the array?", log: .default, type: .error)
                return
            }

            let windmill = Windmill.make(project: project)
            self.makeMainWindowKeyAndOrderFront(windmill: windmill, project: project)
        }
    }
    
    @objc func willStartProject(_ aNotification: Notification) {
        self.statusItem.button?.image = #imageLiteral(resourceName: "statusItem-active")
        self.statusItem.button?.toolTip = ""
        self.statusItem.toolTip = NSLocalizedString("windmill.toolTip.active", comment: "")
        self.activityMenuItem.toolTip = ""
        self.canCleanDerivedData = false
        self.canRemoveCheckoutFolder = false
        self.errorSummariesWindowController?.errorSummariesViewController?.errorSummaries = []
        self.testFailureSummariesWindowController?.testFailureSummariesViewController?.testFailureSummaries = []
    }
    
    @objc func willMonitorProject(_ aNotification: Notification) {
        os_log("will start monitoring", log: .default, type: .debug)

        self.statusItem.toolTip = NSLocalizedString("windmill.toolTip.active.monitor", comment: "")
        self.activityMenuItem.title = NSLocalizedString("windmill.activity.monitor.description", comment: "")
    }
    
    @objc func activityDidLaunch(_ aNotification: Notification) {
        
        guard let activity = aNotification.userInfo?["activity"] as? ActivityType else {
            return
        }

        self.statusItem.toolTip = NSLocalizedString("windmill.toolTip.active.\(activity.rawValue)", comment: "")
        self.activityMenuItem.title = activity.description
    }
    
    @objc func didCheckoutProject(_ aNotification: Notification) {
        
        guard let commit = aNotification.userInfo?["commit"] as? Repository.Commit else {
            os_log("Commit for project not found.", log: .default, type: .debug)
            return
        }
        
        self.commit = commit
    }
    
    @objc func didTestProject(_ aNotification: Notification) {
        
        if let testableSummaries = aNotification.userInfo?["testableSummaries"] as? [TestableSummary] {
            
            let testSummariesWindowController = TestSummariesWindowController.make(testableSummaries: testableSummaries)
            
            self.testSummariesWindowController = testSummariesWindowController
        }        
    }


    @objc func activityError(_ aNotification: Notification) {
        
        NSApplication.shared.requestUserAttention(.criticalRequest)
        
        if let error = aNotification.userInfo?["error"] as? NSError {
            self.statusItem.button?.toolTip = error.localizedDescription
            self.activityMenuItem.toolTip = error.localizedFailureReason
        } else {
            self.statusItem.button?.toolTip = ""
            self.activityMenuItem.toolTip = ""
        }

        self.statusItem.button?.image = #imageLiteral(resourceName: "statusItem")
        self.activityMenuItem.title = NSLocalizedString("windmill.ui.activityTextfield.stopped", comment: "")
        self.canCleanDerivedData = true
        self.canRemoveCheckoutFolder = true
        
        if let errorSummaries = aNotification.userInfo?["errorSummaries"] as? [ResultBundle.ErrorSummary] {
            self.errorSummariesWindowController = ErrorSummariesWindowController.make()
            self.errorSummariesWindowController?.errorSummariesViewController?.errorSummaries = errorSummaries
        }
        
        if let testFailureSummaries = aNotification.userInfo?["testFailureSummaries"] as? [ResultBundle.TestFailureSummary] {
            self.testFailureSummariesWindowController = TestFailureSummariesWindowController.make()
            self.testFailureSummariesWindowController?.testFailureSummariesViewController?.testFailureSummaries = testFailureSummaries
        }
        
        if let testableSummaries = aNotification.userInfo?["testableSummaries"] as? [TestableSummary] {
            let testSummariesWindowController = TestSummariesWindowController.make(testableSummaries: testableSummaries)
        
            self.testSummariesWindowController = testSummariesWindowController
        }
    }

    func toggleDebugArea(sender: Any? = nil, isCollapsed: Bool? = nil) {
        self.mainWindowController?.toggleDebugArea(isCollapsed: isCollapsed)
    }
    
    @IBAction func toggleDebugArea(_ sender: Any) {
        self.toggleDebugArea(sender: sender)
    }
    
    func toggleSidePanel(sender: Any? = nil, isCollapsed: Bool? = nil) {
        self.mainWindowController?.toggleSidePanel(isCollapsed: isCollapsed)
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

    func run(_ sender: Any, skipCheckout: Bool) {
        guard let project = self.mainWindowController?.project else {
            preconditionFailure("MainWindowViewController should have its project property set. Have you set it?")
        }
        
        let windmill = Windmill.make(project: project)
        self.mainWindowController?.windmill = windmill
        self.toggleDebugArea(sender: sender, isCollapsed: true)
        self.errorSummariesWindowController?.close()
        self.testFailureSummariesWindowController?.close()
        self.testSummariesWindowController?.close()
        
        self.start(windmill: windmill, project: project, skipCheckout: skipCheckout)
    }

    @IBAction func run(_ sender: Any) {
        self.run(sender, skipCheckout: false)
    }

    @IBAction func runSkipCheckout(_ sender: Any) {
        self.run(sender, skipCheckout: true)
    }

    func didSelectScheme(mainWindowController: MainWindowController, project: Project, scheme: String) {
        self.projects = [project]
    }
    
    @IBAction func cleanDerivedData(_ sender: Any) {
        self.mainViewController?.cleanDerivedData()
    }
    
    @IBAction func cleanProjectFolder(_ sender: Any) {

        let alert = NSAlert()
        alert.addButton(withTitle: "Remove")
        alert.addButton(withTitle: "Cancel")
        alert.messageText = "Remove the Checkout Folder?"
        alert.informativeText = "Windmill will clone the repo on the next `Run`."
        alert.alertStyle = .warning
        
        if #available(OSX 10.14, *) {

        } else {
            alert.window.appearance = NSAppearance(named: .vibrantDark)
        }

        guard let window = self.mainWindowController?.window else {
            return
        }
        
        alert.beginSheetModal(for: window) { response in
            
            guard response == .alertFirstButtonReturn else {
                return
            }
            
            if self.mainViewController?.cleanProjectFolder() == true {
                self.run(self)
            }
        }
    }
    
    @IBAction func showProjectFolder(_ sender: Any) {
        guard let windmill = self.mainViewController?.windmill else {
            return
        }
        
        let projectSourceURL = windmill.configuration.projectRepositoryDirectory.URL
        
        NSWorkspace.shared.openFile(projectSourceURL.path, withApplication: "Terminal")
    }
    
    @IBAction func openFrequentlyAskedQuestions(_ sender: Any) {
        let faqURL = URL(string: "https://windmill.io/faq/")!
        NSWorkspace.shared.open(faqURL)
    }
    
    @IBAction func openVersionHistory(_ sender: Any) {
        let changelogURL = URL(string: "https://windmill.io/changelog/")!
        NSWorkspace.shared.open(changelogURL)
    }
    
    @IBAction func showErrorSummariesWindowController(_ sender: Any?) {
        self.mainWindowController?.show(errorSummariesWindowController: self.errorSummariesWindowController, commit: commit)
    }

    @IBAction func showTestFailureSummariesWindowController(_ sender: Any?) {
        
        switch sender {
        case let testReportButton as TestReportButton:
            if case .failure = testReportButton.testReport {
                self.mainWindowController?.show(testFailureSummariesWindowController: self.testFailureSummariesWindowController, commit: commit)
            }
            return
        case is NSMenuItem:
            self.mainWindowController?.show(testFailureSummariesWindowController: self.testFailureSummariesWindowController, commit: commit)
        default:
            return
        }
    }

    @IBAction func jumpToNextIssue(_ sender: Any) {
        
        let errorSummaries = errorSummariesWindowController?.errorSummariesViewController?.errorSummaries
        let testFailureSummaries = testFailureSummariesWindowController?.testFailureSummariesViewController?.testFailureSummaries
        
        switch (errorSummaries?.count, testFailureSummaries?.count) {
        case (let errorSummaries?, _) where errorSummaries > 0:
            self.showErrorSummariesWindowController(sender)
            self.errorSummariesWindowController?.errorSummariesViewController?.jumpToNextIssue()
        case (_, let testFailureSummaries?) where testFailureSummaries > 0:
            self.showTestFailureSummariesWindowController(sender)
            self.testFailureSummariesWindowController?.testFailureSummariesViewController?.jumpToNextIssue()
        default:
            return
        }
    }
    
    @IBAction func jumpToPreviousIssue(_ sender: Any) {
        
        let errorSummaries = errorSummariesWindowController?.errorSummariesViewController?.errorSummaries
        let testFailureSummaries = testFailureSummariesWindowController?.testFailureSummariesViewController?.testFailureSummaries
        
        switch (errorSummaries?.count, testFailureSummaries?.count) {
        case (let errorSummaries?, _) where errorSummaries > 0:
            self.showErrorSummariesWindowController(sender)
            self.errorSummariesWindowController?.errorSummariesViewController?.jumpToPreviousIssue()
        case (_, let testFailureSummaries?) where testFailureSummaries > 0:
            self.showTestFailureSummariesWindowController(sender)
            self.testFailureSummariesWindowController?.testFailureSummariesViewController?.jumpToPreviousIssue()
        default:
            return
        }
    }
    
    @IBAction func showTestSummariesWindowController(_ sender: Any?) {
        testSummariesWindowController?.showWindow(self)
    }
}
