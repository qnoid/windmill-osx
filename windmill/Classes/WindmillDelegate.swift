//
//  WindmillDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 17/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

protocol WindmillDelegate
{
    func windmill(windmill: Windmill, standardOutput: String)
    
    func windmill(windmill: Windmill, standardError: String)

    func windmill(windmill: Windmill, willDeployProject project: Project)

    /**
    Callback when Windmill#add: succesfully added a project
    
    - parameter windmill: the Windmill instance associated with the delegate
    - parameter projects: the total number of projects in windmill
    - parameter project: the project for the given 'localGitRepo' at the time #add: was called
    */
    func windmill(windmill: Windmill, projects:Array<Project>, addedProject project: Project)
}