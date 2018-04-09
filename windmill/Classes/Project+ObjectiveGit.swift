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

public struct Repository: CustomDebugStringConvertible {

    public typealias LocalURL = URL    

    static func parse(localGitRepoURL: URL) throws -> Repository.Commit {
        
        let log = OSLog(subsystem: "io.windmill.windmill", category: "repository")
        os_log("%{public}@", log: log, type: .debug, "Using: \(localGitRepoURL.path)")

        do {
            let repo = try GTRepository(url: localGitRepoURL)
            
            guard let currentBranch = try? repo.currentBranch(), let branch = currentBranch.shortName else {
                os_log("%{public}@", log: log, type: .error, "Could not fetch branch")
                throw NSError.errorRepo(localGitRepoURL.path, underlyingError:nil)
            }
            
            guard let head = try repo.headReference().oid, let shortSha = head.sha?.git_shortUniqueSha() else {
                os_log("%{public}@", log: log, type: .error, "Could not fetch head")
                throw NSError.errorRepo(localGitRepoURL.path, underlyingError:nil)
            }
            
            let name = localGitRepoURL.lastPathComponent
            let remote = try repo.configuration().remotes?.filter { remote in
                return remote.name == "origin"
            }
            
            guard let origin = remote?.first?.urlString else {
                os_log("%{public}@", log: log, type: .error, "Could not fetch origin")
                throw NSError.noOriginError(localGitRepoURL.path)
            }
            
            os_log("%{public}@", log: log, type: .debug, "Found remote repo at: \(String(describing: origin))")
            
            let repository = Repository(name: name, origin: origin)
            let commit = Repository.Commit(repository: repository, branch: branch, shortSha: shortSha)
            
            return commit
            
        }
        catch let error as NSError {
            os_log("%{public}@", log: log, type: .debug, "Could not open repository: \(error)")
            throw NSError.errorNoRepo(localGitRepoURL.path)
        }
    }
    
    static func parse(fullPathOfLocalGitRepo localGitRepo: String) throws -> Repository.Commit {
        return try parse(localGitRepoURL: URL(fileURLWithPath: localGitRepo, isDirectory: true))
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
    
    public var debugDescription: String {
        return "\(name):\(origin)"
    }
}

extension Project {
    
    static func make(isWorkspace: Bool? = nil, repository: Repository) -> Project {
        return make(isWorkspace: isWorkspace, name: repository.name, repository: repository)
    }
    
    static func make(isWorkspace: Bool? = nil, name: String, repository: Repository) -> Project {
        return Project(isWorkspace: isWorkspace, name: name, scheme: repository.name, origin: repository.origin)
    }
}
