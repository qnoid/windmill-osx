//
//  MainWindowController.swift
//  windmill
//
//  Created by Markos Charatzas on 10/01/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit

class MainWindowController: NSWindowController, NSToolbarDelegate {
    
    @IBOutlet weak var toolbar: NSToolbar! {
        didSet {
            toolbar.delegate = self
        }
    }
    @IBOutlet weak var panels: NSSegmentedControl!

    weak var debugAreaMenuItem: NSMenuItem!
    weak var sidePanelMenuItem: NSMenuItem!    

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
                self?.sidePanelMenuItem.title = isCollapsed ? NSLocalizedString("windmill.ui.toolbar.view.showSidePanel", comment: ""): NSLocalizedString("windmill.ui.toolbar.view.hideSidePanel", comment: "")
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
                self?.debugAreaMenuItem.title = isCollapsed ? NSLocalizedString("windmill.ui.toolbar.view.showDebugArea", comment: "") : NSLocalizedString("windmill.ui.toolbar.view.hideDebugArea", comment: "")
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
        self.window?.collectionBehavior = [self.window!.collectionBehavior, NSWindow.CollectionBehavior.fullScreenAllowsTiling]
        self.window?.addTitlebarAccessoryViewController(self.projectTitlebarAccessoryViewController)
        self.window?.titleVisibility = .hidden
        self.window?.appearance = NSAppearance(named: .vibrantDark)

        NotificationCenter.default.post(name: Notification.Name("mainWindowDidLoad"), object: self)
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
