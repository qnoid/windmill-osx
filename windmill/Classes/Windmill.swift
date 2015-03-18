//
//  Windmill.swift
//  windmill
//
//  Created by Markos Charatzas on 13/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation
import SwiftGit2
import LlamaKit


public typealias WindmillProvider = () -> Windmill

/// domain is WindmillDomain. code: WindmillErrorCode(s), has its userInfo set with NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey and NSUnderlyingErrorKey set
public typealias WindmillError = NSError

typealias Domain = String

let WindmillDomain : Domain = "io.windmill"

func parse(fullPathOfLocalGitRepo localGitRepo: String) -> Result<Project, WindmillError>
{
    if let localGitRepoURL = NSURL(fileURLWithPath: localGitRepo)
    {
        let repo = Repository.atURL(localGitRepoURL)
        
        if let repo = repo.value
        {
            let latestCommit: Result<Commit, NSError> = repo.HEAD().flatMap { commit in repo.commitWithOID(commit.oid) }
            
            if let commit = latestCommit.value
            {
                Windmill.logger.log(.INFO, "Latest Commit: \(commit.message) by \(commit.author.name)")
                
                let name = localGitRepoURL.lastPathComponent!
                let origin = repo.allRemotes().value![0].URL
                
                return success(Project(name: name, origin: origin))
            }
            else if let error = latestCommit.error {
                Windmill.logger.log(.ERROR, "Could not get commit: \(error)")
                return failure(NSError.errorCommit(error))
            }
        }
        else if let error = repo.error {
            Windmill.logger.log(.ERROR, "Could not open repository: \(error)")
            return failure(NSError.errorRepo(localGitRepo, underlyingError:error))
        }
    }

    Windmill.logger.log(.ERROR, "Error parsing location of local git repo: \(localGitRepo)")
    
    return failure(NSError.errorNoRepo(localGitRepo))
}

final public class Windmill
{
    class func windmill(keychain: Keychain) -> Windmill
    {
        let projects = read(NSInputStream.inputStreamOnProjects())
        
        self.logger.log(.DEBUG, projects)
        
        let windmill = Windmill(keychain: keychain)
        windmill.projects = projects
        
        return windmill
    }
    
    static let logger : ConsoleLog = ConsoleLog()
    
    var delegate: WindmillDelegate?
    
    let scheduler: Scheduler
    let keychain: Keychain
    
    var projects : Array<Project>
    
    public convenience init()
    {
        self.init(scheduler: Scheduler(), keychain: Keychain.defaultKeychain())
    }

    convenience init(keychain: Keychain)
    {
        self.init(scheduler: Scheduler(), keychain: keychain)
    }

    convenience init(scheduler: Scheduler)
    {
        self.init(scheduler: scheduler, keychain: Keychain.defaultKeychain())
    }

    required public init(scheduler: Scheduler, keychain: Keychain)
    {
        self.scheduler = scheduler
        self.keychain = keychain
        self.projects = []
    }
    
    func add(project: Project)
    {
        self.projects.append(project)
        
        write(self.projects, NSOutputStream.outputStreamOnProjects())
        
        self.delegate?.created(self, projects:self.projects, project: project)
    }
    
    /**

    /**
    
    Adds the 'localGitRepo' to the list of projects.
    
    If #delegate is set, you will receive a callback to WindmillDelegate#created(self, projects:self.projects, project: project)
    if the project was

    :precondition: the given 'localGitRepo' must have a remote origin
    :precondition: the given 'localGitRepo' must have at least a commit in its remote origin
    
    :param: localGitRepo the local git repo to add to Windmill
    :returns: true if the 'localGitRepo' was added, false if already added
    */

    project was added
    project not be added
    project failed to create
    
    */
    public func deployGitRepo(localGitRepo: String, project: Project) -> Bool
    {
        if(contains(self.projects, project)){
            Windmill.logger.log(.INFO, "Project already added: \(project)")
            return false
        }
        
        self.add(project)
        self.deployGitRepo(localGitRepo)
        
        return true
    }
    
    func deployGitRepo(localGitRepo : String)
    {
        let taskOnCommit = NSTask.taskOnCommit(localGitRepo: localGitRepo)
        self.scheduler.queue(taskOnCommit)
        
        if let user = self.keychain.findWindmillUser()
        {
            let deployGitRepoForUserTask = NSTask.taskNightly(localGitRepo: localGitRepo, forUser:user)
            
            deployGitRepoForUserTask.addDependency(taskOnCommit){
                self.scheduler.queue(deployGitRepoForUserTask)
                self.scheduler.schedule {
                    return NSTask.taskPoll(localGitRepo)
                    }(ifDirty: {
                        [unowned self] in
                        self.deployGitRepo(localGitRepo)
                        })
            }
        }
    }
}