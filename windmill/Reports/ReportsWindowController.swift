//
//  ReportsWindowController.swift
//  windmill
//
//  Created by Markos Charatzas on 4/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Cocoa

class ReportsWindowController: NSWindowController, ErrorSummariesViewControllerDelegate {
    lazy var splitViewController = self.contentViewController as? NSSplitViewController
    
    lazy var errorSummariesViewController: ErrorSummariesViewController? = {
        guard let splitViewController = splitViewController else {
            return nil
        }
        
        return splitViewController.childViewControllers[0] as? ErrorSummariesViewController
    }()
    
    lazy var infoViewController: InfoViewController? = {
        guard let splitViewController = splitViewController else {
            return nil
        }
        
        return splitViewController.childViewControllers[1] as? InfoViewController
    }()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        guard let window = self.window else {
            return
        }

        window.collectionBehavior = [window.collectionBehavior, NSWindow.CollectionBehavior.fullScreenAllowsTiling]
        
        window.titleVisibility = .hidden
    }
    
    func toggleInfoPane(isCollapsed: Bool? = nil) {
        
        NSAnimationContext.runAnimationGroup({ [infoSplitViewItem  = self.splitViewController?.splitViewItem(for: self.infoViewController!)]_ in
            infoSplitViewItem?.animator().isCollapsed = isCollapsed ?? !infoSplitViewItem!.isCollapsed
        }, completionHandler: nil)
    }

    func didSelect(_ errorSummariesViewController: ErrorSummariesViewController, errorSummary: ResultBundle.ErrorSummary) {
        self.infoViewController?.errorSummary = errorSummary
    }
    
    func doubleAction(_ errorSummariesViewController: ErrorSummariesViewController, errorSummary: ResultBundle.ErrorSummary) {
        self.toggleInfoPane()
        self.infoViewController?.errorSummary = errorSummary
    }
}
