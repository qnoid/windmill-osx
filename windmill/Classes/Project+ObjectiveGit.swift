//
//  Project+ObjectiveGit.swift
//  windmill
//
//  Created by Markos Charatzas on 12/07/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import Foundation
import ObjectiveGit
import os

extension Project {
    
    static func parse(fullPathOfLocalGitRepo localGitRepo: String) throws -> Project
    {
        os_log("%{public}@", log: .default, type: .debug, "Using: \(localGitRepo)")
        
        let localGitRepoURL: URL? = URL(fileURLWithPath: localGitRepo, isDirectory: true)
        
        guard let _localGitRepoURL = localGitRepoURL else {
            os_log("%{public}@", log: .default, type: .error, "Error parsing location of local git repo: \(localGitRepo)")
            throw NSError.errorNoRepo(localGitRepo)
        }
        
        do {
            let repo = try GTRepository(url: _localGitRepoURL)
            
            guard let head = try repo.headReference().oid, let latestCommit:GTCommit = try repo.lookUpObject(by: head) as? GTCommit else {
                os_log("%{public}@", log: .default, type: .error, "Could not fetch head")
                throw NSError.errorRepo(localGitRepo, underlyingError:nil)
            }
            
            os_log("%{public}@", log: .default, type: .info, "Latest Commit: \(latestCommit.message ?? "") by \(latestCommit.author?.name ?? "")")
            
            let name = _localGitRepoURL.lastPathComponent
            let origin = try! repo.configuration().remotes?.filter { remote in
                return remote.name == "origin"
                }[0].urlString!
            
            os_log("%{public}@", log: .default, type: .debug, "Project name: \(name)")
            os_log("%{public}@", log: .default, type: .debug, "Found remote repo at: \(String(describing: origin))")
            
            return Project(name: name, scheme: name, origin: origin!)
            
        }
        catch let error as NSError {
            os_log("%{public}@", log: .default, type: .error, "Could not open repository: \(error)")
            throw NSError.errorRepo(localGitRepo, underlyingError:error)
        }
    }
    

}
