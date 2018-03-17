//
//  ErrorSummariesWindowController.swift
//  windmill
//
//  Created by Markos Charatzas on 4/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Cocoa

class ErrorSummariesWindowController: NSWindowController, ErrorSummariesViewControllerDelegate {
    
    static func make() -> ErrorSummariesWindowController? {
        
        let errorSummariesStoryboard = NSStoryboard.Windmill.errorSummariesStoryboard()
        
        let errorSummariesWindowController = errorSummariesStoryboard.instantiateInitialController() as? ErrorSummariesWindowController
        let errorSummariesViewController = errorSummariesWindowController?.errorSummariesViewController
        errorSummariesViewController?.delegate = errorSummariesWindowController
        
        return errorSummariesWindowController
    }
    
    typealias S = ResultBundle.ErrorSummary
    
    lazy var splitViewController = self.contentViewController as? NSSplitViewController
    
    lazy var errorSummariesViewController: ErrorSummariesViewController? = {
        guard let splitViewController = splitViewController else {
            return nil
        }
        
        return splitViewController.childViewControllers[0] as? ErrorSummariesViewController
    }()
    
    lazy var summaryViewController: SummaryViewController? = {
        guard let splitViewController = splitViewController else {
            return nil
        }
        
        return splitViewController.childViewControllers[1] as? SummaryViewController
    }()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        guard let window = self.window else {
            return
        }

        window.collectionBehavior = [window.collectionBehavior, NSWindow.CollectionBehavior.fullScreenAllowsTiling]
        
        window.titleVisibility = .hidden
    }
    
    func toggleSummaryPane(isCollapsed: Bool? = nil) {
        
        NSAnimationContext.runAnimationGroup({ [summarySplitViewItem  = self.splitViewController?.splitViewItem(for: self.summaryViewController!)]_ in
            summarySplitViewItem?.animator().isCollapsed = isCollapsed ?? !summarySplitViewItem!.isCollapsed
        }, completionHandler: nil)
    }

    func didSelect(_ errorSummariesViewController: ErrorSummariesViewController, errorSummary: ResultBundle.ErrorSummary) {
        self.summaryViewController?.summary = errorSummary
    }
    
    func doubleAction(_ errorSummariesViewController: ErrorSummariesViewController, errorSummary: ResultBundle.ErrorSummary) {
        self.toggleSummaryPane()
        self.summaryViewController?.summary = errorSummary
    }
}
