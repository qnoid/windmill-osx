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
    /**
    Callback when Windmill#add: succesfully added a project
    
    :param: windmill the Windmill instance associated with the delegate
    :param: projects the total number of projects in windmill
    :param: project the project for the given 'localGitRepo' at the time #add: was called
    */
    func created(windmill: Windmill, projects:Array<Project>, project: Project)    
}