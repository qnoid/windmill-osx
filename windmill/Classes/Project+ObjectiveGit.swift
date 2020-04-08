//
//  Project+ObjectiveGit.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 12/07/2017.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
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
            let repo = try GTRepository(url: localGitRepoURL, flags: GTRepositoryOpenFlags.bare.rawValue, ceilingDirs: [localGitRepoURL])
            
            guard let currentBranch = try? repo.currentBranch(), let branch = currentBranch.shortName else {
                os_log("%{public}@", log: log, type: .error, "Could not fetch branch")
                throw NSError.errorRepo(localGitRepoURL.path, underlyingError:nil)
            }
            
            guard let head = try repo.headReference().oid, let shortSha = head.sha.git_shortUniqueSha() else {
                os_log("%{public}@", log: log, type: .error, "Could not fetch head")
                throw NSError.errorRepo(localGitRepoURL.path, underlyingError:nil)
            }

            guard let commit = try? repo.lookUpObject(bySHA: head.sha) as? GTCommit, let author = commit.author, let time = author.time else {
                os_log("%{public}@", log: log, type: .error, "Could not look up commit")
                throw NSError.errorRepo(localGitRepoURL.path, underlyingError:nil)
            }
            
            
            let name = localGitRepoURL.lastPathComponent
            let remotes = try repo.configuration().remotes
            
            let remote = remotes?.first { remote in
                return remote.name == "origin"
            } ?? remotes?.first
            
            guard let origin = remote?.urlString else {
                os_log("%{public}@", log: log, type: .error, "Could not find a remote server in the git repo for the project. You can use `git remote -v` in your repository to confirm. Windmill uses SSH authentication to clone your project. See more in the Help menu, under Getting Started > Where to Start.")
                throw NSError.noOriginError(localGitRepoURL.path)
            }
            
            os_log("%{public}@", log: log, type: .debug, "Found remote repo at: \(String(describing: origin))")
            
            let repository = Repository(name: name, origin: origin)

            return Repository.Commit(repository: repository, branch: branch, shortSha: shortSha, author: author.name, date: time)
            
        }
        catch let error as NSError {
            os_log("%{public}@", log: log, type: .debug, "Could not open repository: \(error)")
            throw NSError.errorNoRepo(localGitRepoURL.path)
        }
    }
    
    static func parse(fullPathOfLocalGitRepo localGitRepo: String) throws -> Repository.Commit {
        return try parse(localGitRepoURL: URL(fileURLWithPath: localGitRepo, isDirectory: true))
    }

    public struct Commit: CustomDebugStringConvertible, Encodable {
        
        enum CodingKeys: CodingKey {
            case branch
            case shortSha
            case date
        }
        
        let repository: Repository
        let branch: String
        let shortSha: String
        let author: String?
        let date: Date

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.branch, forKey: .branch)
            try container.encode(self.shortSha , forKey: .shortSha)
            try container.encode(self.date , forKey: .date)
        }
        
        public var debugDescription: String {
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
    
    static func make(isWorkspace: Bool, repository: Repository) -> Project {
        return make(isWorkspace: isWorkspace, name: repository.name, repository: repository)
    }
    
    static func make(isWorkspace: Bool, name: String, repository: Repository) -> Project {
        return Project(isWorkspace: isWorkspace, name: name, scheme: name, origin: repository.origin)
    }    
}
