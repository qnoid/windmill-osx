//
//  SummariesViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 16/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import AppKit

protocol SummariesViewController {

    var tableView: NSTableView! { get set }
    
    func jumpToNextIssue()
    
    func jumpToPreviousIssue()
}

extension SummariesViewController {
    
    public func jumpToNextIssue() {
        let next = min(self.tableView.numberOfRows, self.tableView.selectedRow + 1)
        let nextSelectRowIndex = IndexSet(integer: next)
        
        self.tableView.selectRowIndexes(nextSelectRowIndex, byExtendingSelection: false)
    }
    
    public func jumpToPreviousIssue() {
        let previous = max(0, self.tableView.selectedRow - 1)
        let previousSelectRowIndex = IndexSet(integer: previous)
        
        self.tableView.selectRowIndexes(previousSelectRowIndex, byExtendingSelection: false)
    }
}
