//
//  TestErrorSummariesWindowController.swift
//  windmill
//
//  Created by Markos Charatzas on 16/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Cocoa

class TestFailureSummariesWindowController: NSWindowController, TestFailureSummariesViewControllerDelegate {
    
    static func make() -> TestFailureSummariesWindowController? {
        
        let testFailureSummariesStoryboard = NSStoryboard.Windmill.testFailureSummariesStoryboard()
        
        let testFailureSummariesWindowController = testFailureSummariesStoryboard.instantiateInitialController() as? TestFailureSummariesWindowController
        let testFailureSummariesViewController = testFailureSummariesWindowController?.testFailureSummariesViewController
        testFailureSummariesViewController?.delegate = testFailureSummariesWindowController
        
        return testFailureSummariesWindowController
    }

    lazy var splitViewController = self.contentViewController as? NSSplitViewController
    
    lazy var testFailureSummariesViewController: TestFailureSummariesViewController? = {
        guard let splitViewController = splitViewController else {
            return nil
        }
        
        return splitViewController.childViewControllers[0] as? TestFailureSummariesViewController
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
    
    func toggleSummaryPane(isCollapsed: Bool? = nil, completionHandler: (() -> Swift.Void)? = nil) {
        
        NSAnimationContext.runAnimationGroup({ [summarySplitViewItem  = self.splitViewController?.splitViewItem(for: self.summaryViewController!)]_ in
            summarySplitViewItem?.animator().isCollapsed = isCollapsed ?? !summarySplitViewItem!.isCollapsed
            }, completionHandler: completionHandler)
    }
    
    func didSelect(_ errorSummariesViewController: TestFailureSummariesViewController, testFailureSummary: ResultBundle.TestFailureSummary) {
        guard let textDocumentLocation = testFailureSummary.textDocumentLocation else {
            return
        }

        self.toggleSummaryPane(isCollapsed: false) {
            self.summaryViewController?.summary = TextDocumentLocationSummary(textDocumentLocation: textDocumentLocation)
        }
    }    
}

