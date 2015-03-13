//
//  ProjectsOutlineViewDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import AppKit

public class ProjectsOutlineViewDelegate : NSObject, NSOutlineViewDelegate
{
    static let logger : ConsoleLog = ConsoleLog()
    
    public func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView?
    {
        if let project = item as? Project {
            return self.outlineView(outlineView, viewForTableColumn: tableColumn, project: project)
        }
        else if let header = item as? Header {
            return self.outlineView(outlineView, viewForTableColumn: tableColumn, header: header)
        }

        ProjectsOutlineViewDelegate.logger.log(.WARN, __FUNCTION__)
        ProjectsOutlineViewDelegate.logger.log(.WARN, "Unrecognized data type for the item. Check what types does ProjectsDataSource return")
        
        return nil
    }
    
    /// private
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, project: Project) -> NSTableCellView
    {
        var cell = outlineView.makeViewWithIdentifier("DataCell")
        cell.textField?.stringValue = project.name
        
        return cell
    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, header: Header) -> NSTableCellView
    {
        var cell = outlineView.makeViewWithIdentifier("HeaderCell")
        cell.textField?.stringValue = header
        
        return cell
    }

}