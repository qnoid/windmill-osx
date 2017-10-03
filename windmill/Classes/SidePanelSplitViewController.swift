//
//  SidePanelSplitViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 27/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import AppKit

class SidePanelSplitViewController: NSSplitViewController {
    
    @IBOutlet weak var mainViewSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var sideViewSplitViewItem: NSSplitViewItem! {
        didSet{
            sideViewSplitViewItem.canCollapse = true
        }
    }

    var bottomPanelSplitViewController: BottomPanelSplitViewController? {
        return self.childViewControllers[0] as? BottomPanelSplitViewController
    }
    
    var mainViewController: MainViewController? {
        return self.bottomPanelSplitViewController?.mainViewController
    }
    
    var sidePanelViewController: SidePanelViewController? {
        return self.childViewControllers[1] as? SidePanelViewController
    }
    
    var isSidePanelHidden: Bool {
        get {
            return self.sideViewSplitViewItem.isCollapsed
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func toggleSidePanel(isCollapsed: Bool? = nil, completionHandler: @escaping (_ isHidden: Bool) -> Void = {_ in }) {
        NSAnimationContext.runAnimationGroup({ _ in
            self.sideViewSplitViewItem.animator().isCollapsed = isCollapsed ?? !self.sideViewSplitViewItem.isCollapsed
            if !self.isSidePanelHidden {
                self.sidePanelViewController?.toggle(isHidden: self.isSidePanelHidden)
            }
        }, completionHandler: {
            if self.isSidePanelHidden {
                self.sidePanelViewController?.toggle(isHidden: self.isSidePanelHidden)
            }
            completionHandler(self.isSidePanelHidden)
        })
    }
    
    func onCollapsed(changeHandler: @escaping (NSSplitViewItem, NSKeyValueObservedChange<Bool>) -> Void) -> NSKeyValueObservation {
        return sideViewSplitViewItem.observe(\.isCollapsed, options: [.initial, .new], changeHandler: changeHandler)
    }
}
