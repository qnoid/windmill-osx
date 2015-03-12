//
//  Project.swift
//  windmill
//
//  Created by Markos Charatzas on 11/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

final public class Project : Hashable, Equatable
{
    public var hashValue: Int {
        return self.origin.hashValue
    }
    
    let name : String
    
    /// the origin of the git repo as returned by 'git remote -v', i.e. git@bitbucket.org:qnoid/balance.git
    let origin : String
    
    public required init(name: String, origin: String)
    {
        self.name = name
        self.origin = origin
    }
}

public func == (lhs: Project, rhs: Project) -> Bool {
    return lhs.origin == rhs.origin
}
