//
//  Project.swift
//  windmill
//
//  Created by Markos Charatzas on 11/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

final public class Project : Hashable, Equatable, CustomStringConvertible
{
    static let toDictionary : (Project) -> Dictionary<String, AnyObject> = { project in
        return [
            "name": project.name,
            "scheme": project.scheme,
            "origin": project.origin ]
    }
    
    static let fromDictionary : (object : AnyObject) -> Project = { (object : AnyObject) -> Project in
        return Project(dictionary: object as! Dictionary<String, AnyObject>)
    }
    
    public var hashValue: Int {
        return self.origin.hashValue
    }
    
    public var description: String {
        return self.origin
    }
    
    let name : String
    
    let scheme : String
    
    /// the origin of the git repo as returned by 'git remote -v', i.e. git@bitbucket.org:qnoid/balance.git
    let origin : String
    
    public required init(name: String, scheme: String, origin: String)
    {
        self.name = name
        self.scheme = scheme
        self.origin = origin
    }

    convenience public init(dictionary aDictionary: Dictionary<String, AnyObject>)
    {
        let name = aDictionary["name"] as! String
        let scheme = aDictionary["scheme"] as! String
        let origin = aDictionary["origin"] as! String
        
        self.init(name:name, scheme: scheme, origin:origin)
    }
}