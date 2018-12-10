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
        
        return splitViewController.children[0] as? ErrorSummariesViewController
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
        
        window.titleVisibility = .hidden
    }
    
    func toggleSummaryPane(isCollapsed: Bool? = nil, completionHandler: (() -> Swift.Void)? = nil) {

        NSAnimationContext.runAnimationGroup({ [summarySplitViewItem  = self.splitViewController?.splitViewItem(for: self.summaryViewController!)]_ in
            summarySplitViewItem?.animator().isCollapsed = isCollapsed ?? !summarySplitViewItem!.isCollapsed
        }, completionHandler: completionHandler)
    }

    func didSelect(_ errorSummariesViewController: ErrorSummariesViewController, errorSummary: ResultBundle.ErrorSummary) {
        guard let textDocumentLocation = errorSummary.textDocumentLocation else {
            return
        }
        
        self.toggleSummaryPane(isCollapsed: false) {
            self.summaryViewController?.summary = TextDocumentLocationSummary(textDocumentLocation: textDocumentLocation)
        }
    }    
}
