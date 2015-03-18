//
//  ProjectsOutlineViewDataSource.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import AppKit

public typealias Header = String

/*
 One level deep with headers
*/
final public class ProjectsDataSource : NSObject, NSOutlineViewDataSource
{
    weak var mainWindowController : MainWindowController!
    
    let headers : Array<Header>
    var projects : Array<Project> {
        didSet{
            self.mainWindowController?.reloadData()
        }
    }
    
    public init(projects : Array<Project> = [], headers : Array<Header> = ["Projects"])
    {
        self.projects = projects
        self.headers = headers
    }
    
    public func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int
    {
        return self.headers.count + self.projects.count
    }
    
    public func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return false
    }
    
    public func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject
    {
        if(index == 0){
            return self.headers[0]
        }
        
        var index = index - self.headers.count
        
        return self.projects[index]
    }
    
    // drag and drop support
    //registerForDraggedTypes
    public func outlineView(outlineView: NSOutlineView, pasteboardWriterForItem item: AnyObject?) -> NSPasteboardWriting! {
        return item as! NSPasteboardWriting;
    }
    
    public func outlineView(outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: AnyObject?, proposedChildIndex index: Int) -> NSDragOperation
    {
        return .Generic;
    }
    
    public func outlineView(outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: AnyObject?, childIndex index: Int) -> Bool {
        return self.mainWindowController.performDragOperation(info)
    }
}