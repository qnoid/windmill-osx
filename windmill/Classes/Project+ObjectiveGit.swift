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

struct Repository: CustomDebugStringConvertible {

    static func of(project: Project) throws -> Repository.Commit {
        return try Repository.parse(fullPathOfLocalGitRepo: project.directoryPathURL.path)
    }
    
    static func parse(fullPathOfLocalGitRepo localGitRepo: String) throws -> Repository.Commit
    {
        os_log("%{public}@", log: .default, type: .debug, "Using: \(localGitRepo)")
        
        let localGitRepoURL: URL? = URL(fileURLWithPath: localGitRepo, isDirectory: true)
        
        guard let _localGitRepoURL = localGitRepoURL else {
            os_log("%{public}@", log: .default, type: .error, "Error parsing location of local git repo: \(localGitRepo)")
            throw NSError.errorNoRepo(localGitRepo)
        }
        
        do {
            let repo = try GTRepository(url: _localGitRepoURL)
            
            guard let currentBranch = try? repo.currentBranch(), let branch = currentBranch.shortName else {
                os_log("%{public}@", log: .default, type: .error, "Could not fetch branch")
                throw NSError.errorRepo(localGitRepo, underlyingError:nil)
            }
            
            guard let head = try repo.headReference().oid, let latestCommit:GTCommit = try repo.lookUpObject(by: head) as? GTCommit, let shortSha = head.sha?.git_shortUniqueSha() else {
                os_log("%{public}@", log: .default, type: .error, "Could not fetch head")
                throw NSError.errorRepo(localGitRepo, underlyingError:nil)
            }
            
            os_log("%{public}@", log: .default, type: .info, "Latest Commit: \(latestCommit.message ?? "") by \(latestCommit.author?.name ?? "")")
            
            let name = _localGitRepoURL.lastPathComponent
            let remote = try repo.configuration().remotes?.filter { remote in
                return remote.name == "origin"
            }
            
            guard let origin = remote?[0].urlString else {
                os_log("%{public}@", log: .default, type: .error, "Could not fetch origin")
                throw NSError.errorRepo(localGitRepo, underlyingError:nil)
            }
            
            os_log("%{public}@", log: .default, type: .debug, "Project name: \(name)")
            os_log("%{public}@", log: .default, type: .debug, "Found remote repo at: \(String(describing: origin))")
            
            let repository = Repository(name: name, origin: origin)
            let commit = Repository.Commit(repository: repository, branch: branch, shortSha: shortSha)
            
            return commit
            
        }
        catch let error as NSError {
            os_log("%{public}@", log: .default, type: .error, "Could not open repository: \(error)")
            throw NSError.errorRepo(localGitRepo, underlyingError:error)
        }
    }

    struct Commit: CustomDebugStringConvertible {
        let repository: Repository
        let branch: String
        let shortSha: String
        
        var debugDescription: String {
            return "\(repository) \(branch):\(shortSha)"
        }
    }
    
    let name: String
    let origin: String
    
    var debugDescription: String {
        return "\(name):\(origin)"
    }
}

extension Project {
    
    static func make(repository: Repository) -> Project {
        return Project(name: repository.name, scheme: repository.name, origin: repository.origin)
    }
}
