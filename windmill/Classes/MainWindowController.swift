//
//  MainWindowController.swift
//  windmill
//
//  Created by Markos Charatzas on 10/01/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit


protocol MainWindowControllerDelegate {
    func didSelectScheme(mainWindowController:MainWindowController, project: Project, scheme: String)
}

class MainWindowController: NSWindowController, NSToolbarDelegate, NSMenuItemValidation {
    
    @discardableResult static func make(windmill: Windmill, project: Project, projectTitlebarAccessoryViewController: ProjectTitlebarAccessoryViewController) -> MainWindowController? {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: Bundle(for: self))
        
        let mainWindowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("MainWindowController")) as? MainWindowController
        mainWindowController?.projectTitlebarAccessoryViewController = projectTitlebarAccessoryViewController
        mainWindowController?.windmill = windmill
        mainWindowController?.project = project
        
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
    var delegate: MainWindowControllerDelegate?
    
    var image: NSImage = #imageLiteral(resourceName: "Application") {
        didSet {
            self.schemeButton.itemArray.forEach({ (item) in
                image.size = NSSize(width: 20, height: 20)
                item.image = image
            })
        }
    }

    var project: Project? {
        didSet {
            self.window?.title = project?.filename ?? ""
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
            self.defaultCenter.addObserver(self, selector: #selector(didBuildProject(_:)), name: Windmill.Notifications.didBuildProject, object: windmill)
            self.projectTitlebarAccessoryViewController?.didSet(windmill: windmill)
            self.userMessageView.didSet(windmill: windmill)
        }
    }
    
    lazy var sidePanelSplitViewController: SidePanelSplitViewController? = {
        guard let sidePanelSplitViewController = self.contentViewController as? SidePanelSplitViewController else {
            return nil
        }
        
        self.isSidePanelCollapsedObserver = sidePanelSplitViewController.onCollapsed { [weak self = self](splitviewitem, change) in
            if let isCollapsed = change.newValue {
                sidePanelSplitViewController.sidePanelViewController?.toggle(isHidden: isCollapsed)
                self?.setSidePanel(isOpen: !isCollapsed)
            }
        }

        return sidePanelSplitViewController
    }()
    
    
    lazy var bottomPanelSplitViewController: BottomPanelSplitViewController? = {
        guard let bottomPanelSplitViewController = sidePanelSplitViewController?.bottomPanelSplitViewController else {
            return nil
        }
        
        self.isBottomPanelCollapsedObserver = bottomPanelSplitViewController.onCollapsed { [weak self = self](splitviewitem, change) in
            if let isCollapsed = change.newValue {
                self?.setBottomPanel(isOpen: !isCollapsed)
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
    
    var warnSummariesWindowController: NSWindowController?
    
    var isSidePanelCollapsedObserver: NSKeyValueObservation?
    var isBottomPanelCollapsedObserver: NSKeyValueObservation?
    
    deinit {
        isSidePanelCollapsedObserver?.invalidate()
        isBottomPanelCollapsedObserver?.invalidate()
    }
    
    override init(window: NSWindow?) {
        super.init(window: window)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionFailed(notification:)), name: SubscriptionManager.SubscriptionFailed, object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionFailed(notification:)), name: SubscriptionManager.SubscriptionFailed, object: nil)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        guard let window = self.window else {
            return
        }
        
        window.collectionBehavior = [window.collectionBehavior, NSWindow.CollectionBehavior.fullScreenAllowsTiling]

        window.title = project?.filename ?? ""
        window.titleVisibility = .hidden
        if #available(OSX 10.14, *) {
            
        } else {
            window.appearance = NSAppearance(named: .vibrantDark)
        }
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(refreshSubscription(_:)) {
            let account = try? Keychain.default.read(key: .account)
    
            switch account {
            case .some: return true
            case .none: return false
            }
        }
        
        return true
    }
    
    fileprivate func addItems(with titles: [String], didAddItems: (NSPopUpButton) -> Swift.Void) {
        titles.forEach { (title) in
            self.schemeButton.addItem(withTitle: title)
            self.schemeButton.lastItem?.image = self.image
        }

        didAddItems(self.schemeButton)
        self.didSelectScheme(self.schemeButton)
    }
    
    @objc func willRun(_ aNotification: Notification) {
        self.schemeButton.removeAllItems()
        self.warnSummariesWindowController?.close()
    }
    
    @objc func activityError(_ aNotification: Notification) {
        
        guard let error = aNotification.userInfo?["error"] as? NSError else {
            return
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

    @IBAction func didSelectScheme(_ sender: NSPopUpButton) {
        guard let scheme = sender.titleOfSelectedItem, let project = self.project else {
            return
        }
        
        let newValue = Project(isWorkspace: project.isWorkspace, name: project.name, scheme: scheme, origin: project.origin)
        self.delegate?.didSelectScheme(mainWindowController: self, project: newValue, scheme: scheme)
        self.project = newValue
    }
    
    func show(errorSummariesWindowController: ErrorSummariesWindowController?, commit: Repository.Commit?) {
        errorSummariesWindowController?.errorSummariesViewController?.commit = commit
        errorSummariesWindowController?.showWindow(self)
    }

    func show(testFailureSummariesWindowController: TestFailureSummariesWindowController?, commit: Repository.Commit?) {
        testFailureSummariesWindowController?.testFailureSummariesViewController?.commit = commit
        testFailureSummariesWindowController?.showWindow(self)
    }
    
    @IBAction func showWarnSummariesWindowController(_ sender: Any?) {
        self.warnSummariesWindowController?.showWindow(self)
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
    
    func toggleSidePanel(isCollapsed: Bool? = nil) {
        self.sidePanelSplitViewController?.toggleSidePanel(isCollapsed: isCollapsed)
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
        
        let warnSummariesWindowController = NSStoryboard.Windmill.warnSummariesStoryboard().instantiateInitialController() as? NSWindowController
        let warnSummariesViewController = warnSummariesWindowController?.contentViewController as? WarnSummariesViewController
        warnSummariesViewController?.warnSummaries = [WarnSummary(error: error)]
        
        self.warnSummariesWindowController = warnSummariesWindowController
    }
}
