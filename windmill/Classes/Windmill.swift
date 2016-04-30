//
//  Windmill.swift
//  windmill
//
//  Created by Markos Charatzas on 13/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation
import SwiftGit2
import Result


public typealias WindmillProvider = () -> Windmill

/// domain is WindmillDomain. code: WindmillErrorCode(s), has its userInfo set with NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey and NSUnderlyingErrorKey set
public typealias WindmillError = NSError

typealias Domain = String

let WindmillDomain : Domain = "io.windmill"

public func parse(fullPathOfLocalGitRepo localGitRepo: String) -> Result<Project, WindmillError>
{
    Windmill.logger.log(.DEBUG, "Using: \(localGitRepo)")
    
    let localGitRepoURL: NSURL? = NSURL(fileURLWithPath: localGitRepo, isDirectory: true)
    
    guard let _localGitRepoURL = localGitRepoURL else {
        Windmill.logger.log(.ERROR, "Error parsing location of local git repo: \(localGitRepo)")
        
        return Result.Failure(NSError.errorNoRepo(localGitRepo))
    }
    
    let repo = Repository.atURL(_localGitRepoURL)
    
    guard let _repo = repo.value else {
        Windmill.logger.log(.ERROR, "Could not open repository: \(repo.error)")
        return Result.Failure(NSError.errorRepo(localGitRepo, underlyingError:repo.error!))
    }
    
    let latestCommit: Result<Commit, NSError> = _repo.HEAD().flatMap { commit in _repo.commitWithOID(commit.oid) }

    guard let _latestCommit = latestCommit.value else {
        Windmill.logger.log(.ERROR, "Could not open repository: \(repo.error)")
        return Result.Failure(NSError.errorRepo(localGitRepo, underlyingError:repo.error!))
    }

    Windmill.logger.log(.INFO, "Latest Commit: \(_latestCommit.message) by \(_latestCommit.author.name)")
    
    let name = _localGitRepoURL.lastPathComponent!
    let origin = _repo.allRemotes().value![0].URL

    Windmill.logger.log(.DEBUG, "Project name: \(name)")
    Windmill.logger.log(.DEBUG, "Found remote repo at: \(origin)")
    
    return Result.Success(Project(name: name, origin: origin))
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
    
    private func add(project: Project)
    {
        self.projects.append(project)
        
        write(self.projects, outputStream: NSOutputStream.outputStreamOnProjects())
        
        self.delegate?.created(self, projects:self.projects, project: project)
    }

    private func deployGitRepo(repoName: String, origin: String)
    {
        let taskCheckout = NSTask.taskCheckout(repoName, origin: origin)
        
        guard let user = try? self.keychain.findWindmillUser() else {
            Windmill.logger.log(.ERROR, "\(__FUNCTION__) A windmill user account should have been created.")
            return
        }
        
        taskCheckout.launch()
        
        let notification = NSTask.Notifications.taskDidLaunchNotification(["type": TaskType.Checkout.rawValue, "origin":origin])
        
        NSNotificationCenter.defaultCenter().postNotification(notification)

        taskCheckout.whenExit { [defaultCenter = NSNotificationCenter.defaultCenter(), nightlyDeployGitRepoForUserTask = NSTask.taskNightly(repoName, origin: origin, forUser:user)] status in
            
            defaultCenter.postNotification(NSTask.Notifications.taskDidExitNotification(.Checkout, terminationStatus: status))
            
            nightlyDeployGitRepoForUserTask.launch()
            defaultCenter.postNotification(NSTask.Notifications.taskDidLaunchNotification(["type": TaskType.Nightly.rawValue, "origin":origin]))
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                
                let status = nightlyDeployGitRepoForUserTask.waitUntilStatus()
                
                dispatch_async(dispatch_get_main_queue()){[defaultCenter = NSNotificationCenter.defaultCenter()] in
                    defaultCenter.postNotification(NSTask.Notifications.taskDidExitNotification(.Nightly, terminationStatus: status))
                }
            }
            
            self.scheduler.schedule(taskProvider: NSTask.taskPoll(repoName), ifDirty: { [unowned self] in
                    self.deployGitRepo(repoName, origin: origin)
                    })
        }
    }
    
    /**

    /**
    
    Adds the given *project* to the list of projects.
    
    If #delegate is set, you will receive a callback to WindmillDelegate#created(self, projects:self.projects, project: project)
    if the project was

    - precondition: the given *project* must have a valid remote origin
    
    - parameter project: the project to add to Windmill
    - returns: true if the 'project' was added, false if already added
    */

    project was added
    project not be added
    project failed to create
    
    */
    public func deploy(project: Project) -> Bool
    {
        guard !self.projects.contains(project) else {
            Windmill.logger.log(.INFO, "Project already added: \(project)")
            return false
        }
        
        self.add(project)
        self.deployGitRepo(project.name, origin: project.origin)
        
        return true
    }
    
    public func start(){
        for project in self.projects {
            self.deployGitRepo(project.name, origin: project.origin)
        }
    }
}