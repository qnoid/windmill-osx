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

class MainWindowController: NSWindowController, NSToolbarDelegate {
    
    @discardableResult static func make(windmill: Windmill, projectTitlebarAccessoryViewController: ProjectTitlebarAccessoryViewController) -> MainWindowController? {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: Bundle(for: self))
        
        let mainWindowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("MainWindowController")) as? MainWindowController
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
    @IBOutlet weak var userMessageView: UserMessageView!
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

    lazy var keychain: Keychain = Keychain.defaultKeychain()
    var windmill: Windmill! {
        didSet{
            let bottomViewController = self.bottomPanelSplitViewController?.bottomViewController
            
            let consoleViewController = bottomViewController?.consoleViewController
            consoleViewController?.windmill = windmill
            let prettyConsoleViewController = bottomViewController?.prettyConsoleViewController
            prettyConsoleViewController?.windmill = windmill
            mainViewController?.windmill = windmill
            sidePanelSplitViewController?.sidePanelViewController?.windmill = windmill
            
            self.defaultCenter.addObserver(self, selector: #selector(willStartProject(_:)), name: Windmill.Notifications.willStartProject, object: windmill)
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
    
    var isSidePanelCollapsedObserver: NSKeyValueObservation?
    var isBottomPanelCollapsedObserver: NSKeyValueObservation?
    
    deinit {
        isSidePanelCollapsedObserver?.invalidate()
        isBottomPanelCollapsedObserver?.invalidate()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        guard let window = self.window else {
            return
        }
        
        window.collectionBehavior = [window.collectionBehavior, NSWindow.CollectionBehavior.fullScreenAllowsTiling]

        window.titleVisibility = .hidden
        window.appearance = NSAppearance(named: .vibrantDark)
    }
    
    fileprivate func addItems(with titles: [String], didAddItems: (NSPopUpButton) -> Swift.Void) {
        titles.forEach { (title) in
            self.schemeButton.addItem(withTitle: title)
            self.schemeButton.lastItem?.image = self.image
        }

        didAddItems(self.schemeButton)
        self.didSelectScheme(self.schemeButton)
    }
    
    @objc func willStartProject(_ aNotification: Notification) {
        self.schemeButton.removeAllItems()
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
            
            if let schemes = configuration.schemes, !schemes.isEmpty {
                addItems(with: schemes) { button in
                    button.selectItem(withTitle: configuration.detectScheme(name: self.windmill.project.scheme))
                }
            }
            else if let targets = configuration.targets, let name = configuration.name, let target = targets.first(where: { return $0.elementsEqual(name) }) {
                addItems(with: [target]) { button in
                    button.selectItem(withTitle: configuration.detectScheme(name: self.windmill.project.scheme))
                }
            } else if let name = configuration.name {
                addItems(with: [name]) { button in
                    button.selectItem(withTitle: configuration.detectScheme(name: self.windmill.project.scheme))
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
        guard let scheme = sender.titleOfSelectedItem else {
            return
        }
        
        let project = windmill.project
        self.windmill.project = Project(isWorkspace: project.isWorkspace, name: project.name, scheme: scheme, origin: project.origin)
        self.delegate?.didSelectScheme(mainWindowController: self, project: self.windmill.project, scheme: scheme)
    }
    
    func show(errorSummariesWindowController: ErrorSummariesWindowController?, commit: Repository.Commit?) {
        errorSummariesWindowController?.errorSummariesViewController?.commit = commit
        errorSummariesWindowController?.showWindow(self)
    }

    func show(testFailureSummariesWindowController: TestFailureSummariesWindowController?, commit: Repository.Commit?) {
        testFailureSummariesWindowController?.testFailureSummariesViewController?.commit = commit
        testFailureSummariesWindowController?.showWindow(self)
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
}
