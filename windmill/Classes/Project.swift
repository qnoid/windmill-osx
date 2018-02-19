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
    public struct Configuration {

        static func make(at url: URL) -> Configuration {
            return Configuration(metadata: MetadataJSONEncoded(url: url))
        }

        private let metadata: Metadata
        let url: URL
        
        init(metadata: Metadata) {
            self.metadata = metadata
            self.url = metadata.url
        }
        
        var project: [String: Any]? {
            return metadata["project"]
        }
        
        var name: String? {
            return project?["name"] as? String
        }
        
        var schemes: [String]? {
            return project?["schemes"] as? [String]
        }

        var configurations: [String]? {
            return project?["configurations"] as? [String]
        }

        var targets: [String]? {
            return project?["targets"] as? [String]
        }
        
        /**
         This method will always make it a priority to return a valid scheme for the project.
         
         If there isn't any valid matching scheme, will return the given `name`.
 
         -note: a "valid" scheme is considered one that can be passed in any of `xcodebuild`s command, such as `-showBuildSettings`, `build`, `build-for-testing`, `test`, `test-without-building`, `archive`.
         -returns: a valid scheme or the given `name` if no valid scheme is found
        */
        func detectScheme(name: String) -> String {
            
            /**
                As of Xcode 9.2, a valid scheme for a project configuration as returned by the "xcodebuild -list" can be
                * any of the schemes available in the project
                * if no schemes are available, any of the targets
            */
            if let schemes = self.schemes, let scheme = schemes.first(where: { return $0.elementsEqual(name) }) {
                return scheme
            }
            else if let schemes = schemes, schemes.isEmpty, let targets = self.targets, let target = targets.first(where: { return $0.elementsEqual(name) }){
                return target
            } else {
                return schemes?.first ?? self.targets?.first ?? self.name ?? name
            }
        }
    }
    
    static let toDictionary : (Project) -> Dictionary<String, Any> = { project in
        return [
            "name": project.name,
            "scheme": project.scheme,
            "origin": project.origin ]
    }

    static let fromDictionary : (_ object : Any) -> Project = { (object : Any) -> Project in
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
