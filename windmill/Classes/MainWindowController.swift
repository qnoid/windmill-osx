//
//  MainWindowController.swift
//  windmill
//
//  Created by Markos Charatzas on 10/01/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit
import os

protocol MainWindowControllerDelegate {
    func sidePanelSplitViewController(mainWindowController: MainWindowController, isCollapsed: Bool)
    func bottomPanelSplitViewController(mainWindowController: MainWindowController, isCollapsed: Bool)
}

class MainWindowController: NSWindowController, NSToolbarDelegate, NSMenuItemValidation, NSWindowDelegate {
    
    @discardableResult static func make(windmill: Windmill) -> MainWindowController? {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: Bundle(for: self))
        
        let mainWindowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("MainWindowController")) as? MainWindowController
        let projectTitlebarAccessoryViewController = ProjectTitlebarAccessoryViewController()
        mainWindowController?.projectTitlebarAccessoryViewController = projectTitlebarAccessoryViewController
        mainWindowController?.windmill = windmill
        
        return mainWindowController
    }

    @IBOutlet weak var toolbar: NSToolbar! {
        didSet {
            toolbar.delegate = self
        }
    }
    @IBOutlet weak var schemeButton: NSPopUpButton!
    @IBOutlet weak var userMessageView: UserMessageToolbarItem!
    @IBOutlet weak var panels: NSSegmentedControl!

    let defaultCenter = NotificationCenter.default
    var delegate: MainWindowControllerDelegate? {
        didSet{
            if let sidePanelSplitViewController = self.sidePanelSplitViewController {
                self.delegate?.sidePanelSplitViewController(mainWindowController: self, isCollapsed: sidePanelSplitViewController.sideViewSplitViewItem.isCollapsed)
            }
            if let bottomPanelSplitViewController = self.bottomPanelSplitViewController {
                self.delegate?.bottomPanelSplitViewController(mainWindowController: self, isCollapsed: bottomPanelSplitViewController.bottomViewSplitViewItem.isCollapsed)
            }
        }
    }
    
    var image: NSImage = #imageLiteral(resourceName: "Application") {
        didSet {
            self.schemeButton.itemArray.forEach({ (item) in
                image.size = NSSize(width: 16, height: 16)
                item.image = image
            })
        }
    }
    
    var configuration: Windmill.Configuration? {
        didSet{
            if let configuration = self.windmill?.configuration {
                self.window?.title = "\(configuration.project) -> \(configuration.branch)"
            }
            
            if let oldValue = oldValue, let configuration = configuration {
                Windmill.Configuration.shared.delete(oldValue)
                Windmill.Configuration.shared.write(configuration)
            }
        }
    }

    var windmill: Windmill? {
        didSet{
            let bottomViewController = self.bottomPanelSplitViewController?.bottomViewController
            
            let consoleViewController = bottomViewController?.consoleViewController
            consoleViewController?.windmill = windmill
            let prettyConsoleViewController = bottomViewController?.prettyConsoleViewController
            prettyConsoleViewController?.windmill = windmill
            mainViewController?.windmill = windmill
            sidePanelSplitViewController?.sidePanelViewController?.windmill = windmill
            
            self.defaultCenter.addObserver(self, selector: #selector(willRun(_:)), name: Windmill.Notifications.willRun, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.didError, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityDidExitSuccesfully(_:)), name: Windmill.Notifications.activityDidExitSuccesfully, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(didCheckoutProject(_:)), name: Windmill.Notifications.didCheckoutProject, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(didBuildProject(_:)), name: Windmill.Notifications.didBuildProject, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(didTestProject(_:)), name: Windmill.Notifications.didTestProject, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(sourceCodeChanged(_:)), name: Windmill.Notifications.SourceCodeChanged, object: windmill)
            self.projectTitlebarAccessoryViewController?.didSet(windmill: windmill)
            self.userMessageView.didSet(windmill: windmill)
            self.configuration = windmill?.configuration
        }
    }
    
    lazy var sidePanelSplitViewController: SidePanelSplitViewController? = {
        guard let sidePanelSplitViewController = self.contentViewController as? SidePanelSplitViewController else {
            return nil
        }
        
        self.isSidePanelCollapsedObserver = sidePanelSplitViewController.onCollapsed { [weak self = self](splitviewitem, change) in
            if let isCollapsed = change.newValue, let self = self {
                self.delegate?.sidePanelSplitViewController(mainWindowController: self, isCollapsed: isCollapsed)
                sidePanelSplitViewController.sidePanelViewController?.toggle(isHidden: isCollapsed)
                self.setSidePanel(isOpen: !isCollapsed)
            }
        }

        return sidePanelSplitViewController
    }()
    
    
    lazy var bottomPanelSplitViewController: BottomPanelSplitViewController? = {
        guard let bottomPanelSplitViewController = sidePanelSplitViewController?.bottomPanelSplitViewController else {
            return nil
        }
        
        self.isBottomPanelCollapsedObserver = bottomPanelSplitViewController.onCollapsed { [weak self = self](splitviewitem, change) in
            if let isCollapsed = change.newValue, let self = self {
                self.delegate?.bottomPanelSplitViewController(mainWindowController: self, isCollapsed: isCollapsed)
                self.setBottomPanel(isOpen: !isCollapsed)
            }
        }

        return bottomPanelSplitViewController
    }()
    
    var mainViewController: MainViewController? {
        return self.sidePanelSplitViewController?.mainViewController
    }
    
    weak var projectTitlebarAccessoryViewController: ProjectTitlebarAccessoryViewController? {
        didSet {
            if let projectTitlebarAccessoryViewController = projectTitlebarAccessoryViewController {
                window?.addTitlebarAccessoryViewController(projectTitlebarAccessoryViewController)
            }
        }
    }
    
    var errorSummariesWindowController: ErrorSummariesWindowController?
    var commit: Repository.Commit?
    
    var testFailureSummariesWindowController: TestFailureSummariesWindowController?
    var testSummariesWindowController: TestSummariesWindowController?
    
    weak var warnSummariesWindowController: NSWindowController?
    var warnings = [Error]()
    
    var canRemoveCheckoutFolder = false
    var canCleanDerivedData = false
    var canLaunchOnSimulator = false
    
    var isSidePanelCollapsedObserver: NSKeyValueObservation?
    var isBottomPanelCollapsedObserver: NSKeyValueObservation?
    
    deinit {
        isSidePanelCollapsedObserver?.invalidate()
        isBottomPanelCollapsedObserver?.invalidate()
    }
    
    override init(window: NSWindow?) {
        super.init(window: window)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionFailed(notification:)), name: SubscriptionManager.SubscriptionFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noUserAccount(notification:)), name: Windmill.Notifications.NoUserAccount, object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionFailed(notification:)), name: SubscriptionManager.SubscriptionFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noUserAccount(notification:)), name: Windmill.Notifications.NoUserAccount, object: nil)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        guard let window = self.window else {
            return
        }
        
        window.collectionBehavior = [window.collectionBehavior, NSWindow.CollectionBehavior.fullScreenAllowsTiling]
        window.titleVisibility = .hidden
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(run(_:)) {
            return self.window?.isVisible ?? false
        } else if menuItem.action == #selector(runSkipCheckout(_:)), let windmill = self.windmill {
            return windmill.isRepositoryDirectoryPresent()
        } else if menuItem.action == #selector(showProjectFolder(_:)), let windmill = self.windmill {
            return windmill.isRepositoryDirectoryPresent()
        } else if menuItem.action == #selector(cleanDerivedData(_:)) {
            return self.canCleanDerivedData
        } else if menuItem.action == #selector(cleanProjectFolder(_:)) {
            return self.canRemoveCheckoutFolder
        } else if menuItem.action == #selector(refreshSubscription(_:)) {
            let account = try? Keychain.default.read(key: .account)
    
            switch account {
            case .some: return true
            case .none: return false
            }
        } else if menuItem.action == #selector(restoreSubscription(_:)) {
            let account = try? Keychain.default.read(key: .account)
            
            switch account {
            case .some: return false
            case .none: return true
            }
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
        } else if menuItem.action == #selector(launchOnSimulator(_:)) {
                return self.canLaunchOnSimulator
        } else if menuItem.action == #selector(recordVideo(_:)) {
            return Preferences.shared.recordVideo
        }

        return true
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
    
    fileprivate func addItems(with titles: [String], didAddItems: (NSPopUpButton) -> Swift.Void) {
        titles.forEach { (title) in
            self.schemeButton.addItem(withTitle: title)
            self.schemeButton.lastItem?.image = self.image
        }

        didAddItems(self.schemeButton)
        self.didSelectScheme(self.schemeButton)
    }
    
    @objc func sourceCodeChanged(_ aNotification: Notification) {
        self.run(aNotification.object ?? self)
    }

    @objc func willRun(_ aNotification: Notification) {
        self.schemeButton.removeAllItems()
        self.errorSummariesWindowController?.errorSummariesViewController?.errorSummaries = []
        self.errorSummariesWindowController?.close()
        self.testFailureSummariesWindowController?.testFailureSummariesViewController?.testFailureSummaries = []
        self.testFailureSummariesWindowController?.close()
        self.warnings = []
        self.warnSummariesWindowController?.close()
        self.canCleanDerivedData = false
        self.canRemoveCheckoutFolder = false
        self.canLaunchOnSimulator = false
        self.toggleDebugArea(sender: aNotification.object, isCollapsed: true)
    }
    
    @objc func activityError(_ aNotification: Notification) {
        
        self.canCleanDerivedData = true
        self.canRemoveCheckoutFolder = true

        guard let error = aNotification.userInfo?["error"] as? NSError else {
            return
        }
        
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
        
        switch error.domain {
        case WindmillErrorDomain, NSPOSIXErrorDomain:
            self.toggleDebugArea(isCollapsed: false)
        default:
            return
        }
    }

    @objc func activityDidExitSuccesfully(_ aNotification: Notification) {
        guard let activity = aNotification.userInfo?["activity"] as? ActivityType else {
            return
        }
        
        switch activity {
        case .readProjectConfiguration:
            
            guard let configuration = aNotification.userInfo?["configuration"] as? Project.Configuration else {
                return
            }
            
            if let schemes = configuration.schemes, !schemes.isEmpty, let scheme = aNotification.userInfo?["scheme"] as? String {
                addItems(with: schemes) { button in
                    button.selectItem(withTitle: scheme)
                }
            }
            else if let targets = configuration.targets, let name = configuration.name, let target = targets.first(where: { return $0.elementsEqual(name) }), let scheme = aNotification.userInfo?["scheme"] as? String {
                addItems(with: [target]) { button in
                    button.selectItem(withTitle: scheme)
                }
            } else if let name = configuration.name, let scheme = aNotification.userInfo?["scheme"] as? String {
                addItems(with: [name]) { button in
                    button.selectItem(withTitle: scheme)
                }
            }
        case .test:
            self.canLaunchOnSimulator = true
        default:
            break
        }
    }
    
    @objc func didBuildProject(_ aNotification: NSNotification) {
        
        guard let appBundle = aNotification.userInfo?["appBundle"] as? AppBundle else {
            return
        }
        
        if let image = NSImage(contentsOf: appBundle.iconURL()) {
            self.image = image
        }
    }

    @objc func didTestProject(_ aNotification: Notification) {
        
        if let testableSummaries = aNotification.userInfo?["testableSummaries"] as? [TestableSummary] {
            
            let testSummariesWindowController = TestSummariesWindowController.make(testableSummaries: testableSummaries)
            self.testSummariesWindowController = testSummariesWindowController
        }
    }
    

    @objc func didCheckoutProject(_ aNotification: Notification) {
        
        guard let commit = aNotification.userInfo?["commit"] as? Repository.Commit else {
            os_log("Commit for project not found.", log: .default, type: .debug)
            return
        }
        
        self.commit = commit
    }

    @IBAction func didSelectScheme(_ sender: NSPopUpButton) {
        guard let scheme = sender.titleOfSelectedItem, let configuration = self.configuration else {
            return
        }
        
        let project = Project(isWorkspace: configuration.project.isWorkspace, name: configuration.project.name, scheme: scheme, origin: configuration.project.origin)
        self.configuration = Windmill.Configuration(project: project, branch: configuration.branch, activities: configuration.activities)
    }
    
    func show(errorSummariesWindowController: ErrorSummariesWindowController?, commit: Repository.Commit?) {
        errorSummariesWindowController?.locations = self.windmill?.locations
        errorSummariesWindowController?.errorSummariesViewController?.commit = commit
        errorSummariesWindowController?.showWindow(self)
    }
    
    @IBAction func showErrorSummariesWindowController(_ sender: Any?) {
        self.show(errorSummariesWindowController: self.errorSummariesWindowController, commit: commit)
    }

    func show(testFailureSummariesWindowController: TestFailureSummariesWindowController?, commit: Repository.Commit?) {
        testFailureSummariesWindowController?.testFailureSummariesViewController?.commit = commit
        testFailureSummariesWindowController?.showWindow(self)
    }
    
    @IBAction func showWarnSummariesWindowController(_ sender: Any?) {
        
        let warnSummariesWindowController = NSStoryboard.Windmill.warnSummariesStoryboard().instantiateInitialController() as? NSWindowController
        let warnSummariesViewController = warnSummariesWindowController?.contentViewController as? WarnSummariesViewController
        warnSummariesViewController?.warnSummaries = self.warnings.map { WarnSummary(error: $0) }
        
        self.warnSummariesWindowController = warnSummariesWindowController
        self.warnSummariesWindowController?.showWindow(self)
    }

    @IBAction func showTestFailureSummariesWindowController(_ sender: Any?) {
        
        switch sender {
        case let testReportButton as TestReportButton:
            if case .failure = testReportButton.testReport {
                self.show(testFailureSummariesWindowController: self.testFailureSummariesWindowController, commit: commit)
            }
            return
        case is NSMenuItem:
            self.show(testFailureSummariesWindowController: self.testFailureSummariesWindowController, commit: commit)
        default:
            return
        }
    }
    
    @IBAction func showTestSummariesWindowController(_ sender: Any?) {
        testSummariesWindowController?.showWindow(self)
    }

    func setBottomPanel(isOpen selected: Bool) {
        self.panels.setSelected(selected, forSegment: 0)
    }

    func setSidePanel(isOpen selected: Bool) {
        self.panels.setSelected(selected, forSegment: 1)
    }
    
    func toggleDebugArea(isCollapsed: Bool? = nil) {
        self.sidePanelSplitViewController?.bottomPanelSplitViewController?.toggleBottomPanel(isCollapsed: isCollapsed)
    }
    
    func toggleDebugArea(sender: Any? = nil, isCollapsed: Bool? = nil) {
        self.toggleDebugArea(isCollapsed: isCollapsed)
    }
    
    @IBAction func toggleDebugArea(_ sender: Any) {
        self.toggleDebugArea(sender: sender)
    }
    
    func toggleSidePanel(isCollapsed: Bool? = nil) {
        self.sidePanelSplitViewController?.toggleSidePanel(isCollapsed: isCollapsed)
    }
    
    func toggleSidePanel(sender: Any? = nil, isCollapsed: Bool? = nil) {
        self.toggleSidePanel(isCollapsed: isCollapsed)
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
        guard let configuration = self.configuration else {
            preconditionFailure("MainWindowViewController should have its windmill property set. Have you set it?")
        }
        
        let windmill = Windmill.make(configuration: configuration)
        self.windmill = windmill
        windmill.run(skipCheckout: skipCheckout)
    }
    
    @IBAction func run(_ sender: Any) {
        self.run(sender, skipCheckout: false)
    }
    
    @IBAction func runSkipCheckout(_ sender: Any) {
        self.run(sender, skipCheckout: true)
    }

    @IBAction func restoreSubscription(_ sender: Any) {
        self.windmill?.restoreSubscription { [weak self] error in
            self?.toggleDebugArea(isCollapsed: false)
        }
    }

    @IBAction func refreshSubscription(_ sender: Any) {
        self.windmill?.refreshSubscription { [weak self] error in
            self?.toggleDebugArea(isCollapsed: false)
        }
    }
    
    @objc func distribute(_ sender: Any) {
        self.windmill?.distribute { [weak self] error in
            self?.toggleDebugArea(isCollapsed: false)
        }
    }
    
    @objc func subscriptionFailed(notification: NSNotification) {
        guard let error = notification.userInfo?["error"] as? Error else {
            return
        }
        
        self.warnings.append(error)
    }
    
    @objc func noUserAccount(notification: NSNotification) {
        self.warnings.append(NSError.errorNoAccount())
    }
    
    @IBAction func cleanDerivedData(_ sender: Any) {
        self.windmill?.removeDerivedData()
    }
    
    @IBAction func cleanProjectFolder(_ sender: Any) {
        
        let alert = NSAlert()
        alert.addButton(withTitle: "Remove")
        alert.addButton(withTitle: "Cancel")
        alert.messageText = "Remove the Checkout Folder?"
        alert.informativeText = "Windmill will clone the repo on the next `Run`."
        alert.alertStyle = .warning
        
        guard let window = self.window else {
            return
        }
        
        alert.beginSheetModal(for: window) { response in
            
            guard response == .alertFirstButtonReturn else {
                return
            }
            
            if self.windmill?.removeRepositoryDirectory() == true {
                self.run(self)
            }
        }
    }
    
    @IBAction func showProjectFolder(_ sender: Any) {
        guard let windmill = self.windmill else {
            return
        }
        
        let repository = windmill.locations.repository
        
        NSWorkspace.shared.openFile(repository.URL.path, withApplication: "Terminal")
    }
    
    @IBAction func recordVideo(_ sender: Any) {
        self.projectTitlebarAccessoryViewController?.recordVideo(sender)
    }
    
    @IBAction func launchOnSimulator(_ sender: Any) {
        self.projectTitlebarAccessoryViewController?.launchOnSimulator(sender)
    }
    
    func windowWillClose(_ notification: Notification) {
        self.windmill?.remove()
    }
    
    func addTabbedWindow(mainWindowController: MainWindowController) {
        guard let window = mainWindowController.window else {
            return
        }
        
        self.window?.addTabbedWindow(window, ordered: .out)
    }
}
