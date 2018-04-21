//
//  BottomPanelSplitViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 16/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import AppKit

class BottomPanelSplitViewController: NSSplitViewController {
    
    @IBOutlet weak var mainViewSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var bottomViewSplitViewItem: NSSplitViewItem! {
        didSet{
            bottomViewSplitViewItem.minimumThickness = 150
            bottomViewSplitViewItem.canCollapse = true
            bottomViewSplitViewItem.isCollapsed = true
        }
    }
    
    var mainViewController: MainViewController? {
        return self.childViewControllers[0] as? MainViewController
    }

    var bottomViewController: BottomTabViewController? {
        return self.childViewControllers[1] as? BottomTabViewController
    }

    var isBottomPanelCollapsed: Bool {
        get {
            return self.bottomViewSplitViewItem.isCollapsed
        }
    }
    
    func toggleBottomPanel(isCollapsed: Bool? = nil, completionHandler: @escaping (_ isHidden: Bool) -> Void = {_ in }) {
        NSAnimationContext.runAnimationGroup({ _ in
            self.bottomViewSplitViewItem.animator().isCollapsed = isCollapsed ?? !self.isBottomPanelCollapsed
            self.bottomViewController?.consoleViewController?.toggle(isHidden: self.isBottomPanelCollapsed)
            self.bottomViewController?.prettyConsoleViewController?.toggle(isHidden: self.isBottomPanelCollapsed)
        }, completionHandler: {
            self.bottomViewController?.consoleViewController?.toggle(isHidden: self.isBottomPanelCollapsed)
            self.bottomViewController?.prettyConsoleViewController?.toggle(isHidden: self.isBottomPanelCollapsed)
            completionHandler(self.isBottomPanelCollapsed)
        })
    }
    
    func onCollapsed(changeHandler: @escaping (NSSplitViewItem, NSKeyValueObservedChange<Bool>) -> Void) -> NSKeyValueObservation {
        return bottomViewSplitViewItem.observe(\.isCollapsed, options: [.new], changeHandler: changeHandler)
    }
}
