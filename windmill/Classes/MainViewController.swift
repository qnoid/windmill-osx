//
//  MainWindowController.swift
//  windmill
//
//  Created by Markos Charatzas on 13/02/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import AppKit

class MainWindowController : NSWindowController, NSOutlineViewDataSource, NSOutlineViewDelegate
{
    override func windowDidLoad() {
        println(__FUNCTION__)
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int
    {
        return 1
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool
    {
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject
    {
        return "balance"
    }
    
//    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool
//    {
//        let item = item as? String
//        
//        return item == "Projects"
//    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView?
    {
        let item = item as! String
        
        var v = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
        if let tf = v.textField {
            tf.stringValue = item
        }
        return v
    }
}