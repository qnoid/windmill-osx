//
//  MainWindowController.swift
//  windmill
//
//  Created by Markos Charatzas on 10/01/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit

class MainWindowController: NSWindowController, NSToolbarDelegate {
    
    @discardableResult static func make(windmill: Windmill) -> MainWindowController? {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: Bundle(for: self))
        
        let mainWindowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("MainWindowController")) as? MainWindowController
        mainWindowController?.windmill = windmill
        
        return mainWindowController
    }

    @IBOutlet weak var toolbar: NSToolbar! {
        didSet {
            toolbar.delegate = self
        }
    }
    @IBOutlet weak var panels: NSSegmentedControl!

    lazy var keychain: Keychain = Keychain.defaultKeychain()
    var windmill: Windmill! {
        didSet{
            let consoleViewController = self.bottomPanelSplitViewController?.consoleViewController
            windmill.processManager.delegate = consoleViewController
            consoleViewController?.windmill = windmill
            mainViewController?.windmill = windmill
            sidePanelSplitViewController?.sidePanelViewController?.windmill = windmill
        }
    }
    
    fileprivate lazy var projectTitlebarAccessoryViewController: ProjectTitlebarAccessoryViewController = { [weak storyboard = self.storyboard] in
        storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ProjectTitlebarAccessoryViewController")) as! ProjectTitlebarAccessoryViewController
        }()
    
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
                bottomPanelSplitViewController.consoleViewController?.toggle(isHidden: isCollapsed)
                self?.setBottomPanel(isOpen: !isCollapsed)
            }
        }

        return bottomPanelSplitViewController
    }()
    
    var mainViewController: MainViewController? {
        return self.sidePanelSplitViewController?.mainViewController
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
        window.addTitlebarAccessoryViewController(self.projectTitlebarAccessoryViewController)
        window.titleVisibility = .hidden
        window.appearance = NSAppearance(named: .vibrantDark)
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
