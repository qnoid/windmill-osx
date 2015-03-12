//
//  ProjectsOutlineViewDataSource.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import AppKit

class ProjectsDataSource : NSObject, NSOutlineViewDataSource
{
    class func projectsDataSource() -> ProjectsDataSource
    {
        return ProjectsDataSource()
    }
    
    
    
    weak var mainWindowController : MainWindowController!
    
    let headers = ["Projects"]
    var projects : Array<Project>
    
    required init(projects : Array<Project> = [])
    {
        self.projects = projects
    }
    
    func add(project : Project) -> Bool
    {
        if(contains(self.projects, project)){
        return false
        }
        
        self.projects.append(project)
        self.mainWindowController.reloadData()
        
        return true
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int
    {
        return self.headers.count + self.projects.count
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool
    {
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject
    {
        if(index == 0){
            return self.headers[0]
        }
        
        var index = index - self.headers.count
        
        return self.projects[index]
    }
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool
    {
        if let header = item as? String {
            return contains(self.headers, header)
        }

    return false
    }
}