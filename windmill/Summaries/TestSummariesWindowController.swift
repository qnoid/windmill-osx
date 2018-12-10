//
//  TestSummariesWindowController.swift
//  windmill
//
//  Created by Markos Charatzas on 23/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Cocoa

class TestSummariesWindowController: NSWindowController, TestSummariesViewControllerDelegate {

    static func make(testableSummaries: [TestableSummary]) -> TestSummariesWindowController? {
        
        let testSummariesStoryboard = NSStoryboard.Windmill.testSummariesStoryboard()
        
        let testSummariesWindowController = testSummariesStoryboard.instantiateInitialController() as? TestSummariesWindowController
        let testSummariesViewController = testSummariesWindowController?.testSummariesViewController
        testSummariesViewController?.delegate = testSummariesWindowController
        testSummariesViewController?.testableSummaries = testableSummaries
        
        return testSummariesWindowController
    }
    
    lazy var splitViewController = self.contentViewController as? NSSplitViewController
    
    lazy var testSummariesViewController: TestSummariesViewController? = {
        guard let splitViewController = splitViewController else {
            return nil
        }
        
        return splitViewController.children[0] as? TestSummariesViewController
    }()
    
    lazy var summaryViewController: SummaryViewController? = {
        guard let splitViewController = splitViewController else {
            return nil
        }
        
        return splitViewController.children[1] as? SummaryViewController
    }()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        guard let window = self.window else {
            return
        }
        
        window.collectionBehavior = [window.collectionBehavior, NSWindow.CollectionBehavior.fullScreenAllowsTiling]
    }
    
    func toggleSummaryPane(isCollapsed: Bool? = nil, completionHandler: (() -> Swift.Void)? = nil) {
        
        NSAnimationContext.runAnimationGroup({ [summarySplitViewItem  = self.splitViewController?.splitViewItem(for: self.summaryViewController!)]_ in
            summarySplitViewItem?.animator().isCollapsed = isCollapsed ?? !summarySplitViewItem!.isCollapsed
            }, completionHandler: completionHandler)
    }
    
    func didSelect(_ testSummariesViewController: TestSummariesViewController, test: Test) {
        self.toggleSummaryPane(isCollapsed: false) {
            self.summaryViewController?.summary = test.failureSummaries.first
        }
    }
}
