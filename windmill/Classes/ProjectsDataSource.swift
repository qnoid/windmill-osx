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
    public class func projectsDataSource() -> ProjectsDataSource
    {
        return ProjectsDataSource()
    }
    
    weak var mainWindowController : MainWindowController!
    
    let headers : Array<Header>
    var projects : Array<Project>
    
    public init(projects : Array<Project> = [], headers : Array<Header> = ["Projects"])
    {
        self.projects = projects
        self.headers = headers
    }
    
    /*
    Adds the 'project' to the datasource.
    
    @postcodition MainWindowController#reloadData will be called if the given 'project' was added
    @param project the project to add to the datasource
    @returns true if the 'project' was added to the datasource, false if already in the datasource
    */
    public func add(project : Project) -> Bool
    {
        if(contains(self.projects, project)){
        return false
        }
        
        self.projects.append(project)
        self.mainWindowController?.reloadData()
        
        return true
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
}