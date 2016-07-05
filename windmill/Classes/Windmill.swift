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


typealias WindmillProvider = () -> Windmill

/// domain is WindmillDomain. code: WindmillErrorCode(s), has its userInfo set with NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey and NSUnderlyingErrorKey set
public typealias WindmillError = NSError

typealias Domain = String

let WindmillDomain : Domain = "io.windmill"

final class Windmill: SchedulerDelegate
{
    static var dispatch_queue_serial = dispatch_queue_create("io.windmil.queue", DISPATCH_QUEUE_SERIAL)
    
    static func dispatch_after(seconds: UInt64, queue: dispatch_queue_t = dispatch_queue_serial, block: dispatch_block_t) {
        
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * NSEC_PER_SEC))
        
        dispatch_after(when, queue: queue, block: block)
    }

    class func windmill(keychain: Keychain) -> Windmill
    {
        let projects = read(NSInputStream.inputStreamOnProjects())
        
        self.logger.log(.DEBUG, projects)
        
        let windmill = Windmill(keychain: keychain)
        windmill.projects = projects
        
        return windmill
    }
    
    static func parse(fullPathOfLocalGitRepo localGitRepo: String) -> Result<Project, NSError>
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
        
        let latestCommit: Result = _repo.HEAD().flatMap { commit in _repo.commitWithOID(commit.oid) }
        
        guard let _latestCommit = latestCommit.value else {
            Windmill.logger.log(.ERROR, "Could not open repository: \(repo.error)")
            return Result.Failure(NSError.errorRepo(localGitRepo, underlyingError:repo.error!))
        }
        
        Windmill.logger.log(.INFO, "Latest Commit: \(_latestCommit.message) by \(_latestCommit.author.name)")
        
        let name = _localGitRepoURL.lastPathComponent!
        let origin = _repo.allRemotes().value![0].URL
        
        Windmill.logger.log(.DEBUG, "Project name: \(name)")
        Windmill.logger.log(.DEBUG, "Found remote repo at: \(origin)")
        
        return Result.Success(Project(name: name, scheme: name, origin: origin))
    }

    
    static let logger : ConsoleLog = ConsoleLog()
    
    var delegate: WindmillDelegate?
    
    let scheduler: Scheduler
    let keychain: Keychain
    
    var projects : Array<Project>
    
    convenience init()
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

    required init(scheduler: Scheduler, keychain: Keychain)
    {
        self.scheduler = scheduler
        self.keychain = keychain
        self.projects = []
        self.scheduler.delegate = self
    }
    
    private func add(project: Project)
    {
        self.projects.append(project)
        
        write(self.projects, outputStream: NSOutputStream.outputStreamOnProjects())
    }

    private func poll(project: Project, ifCaseOfBranchBehindOrigin callback: dispatch_block_t) {
        
        self.scheduler.schedule(task: NSTask.taskPoll(project.name)) { [weak weakSelf = self] task, error in

            guard let _self = weakSelf else {
                return
            }
            
            if case ActivityTaskStatus.BranchBehindOrigin? = task.status {
                callback()
                return
            }
            
            _self.poll(project, ifCaseOfBranchBehindOrigin: callback)
        }
    }
    
    private func monitor(project: Project) {
        self.poll(project, ifCaseOfBranchBehindOrigin: {
            self.deploy(project)
            self.monitor(project)
        })
    }
    
    private func deploy(project: Project)
    {
        guard let user = try? self.keychain.findWindmillUser() else {
            Windmill.logger.log(.ERROR, "\(#function) A windmill user account should have been created.")
            return
        }
        
        self.delegate?.windmill(self, willDeployProject: project)
        
        let name = project.name

        let directoryPath = "\(NSFileManager.defaultManager().windmill)\(name)"
        debugPrint(directoryPath)

        self.scheduler.queue(tasks: NSTask.taskCheckout(name, origin: project.origin),
            NSTask.taskBuild(directoryPath: directoryPath, scheme: project.scheme),
            NSTask.taskTest(directoryPath: directoryPath, scheme: project.scheme),
            NSTask.taskArchive(directoryPath: directoryPath, scheme: project.scheme, projectName: name),
            NSTask.taskExport(directoryPath: directoryPath, projectName: name),
            NSTask.taskDeploy(directoryPath: directoryPath, projectName: name, forUser: user))
    }
    
    func didLaunch(task: ActivityTask, scheduler: Scheduler) {
        NSNotificationCenter.defaultCenter().postNotification(NSTask.Notifications.taskDidLaunchNotification(task.activityType))
    }
    
    func didExit(task: ActivityTask, error: TaskError?, scheduler: Scheduler) {

        if case ActivityTaskStatus.Succesful? = task.status {
            NSNotificationCenter.defaultCenter().postNotification(NSTask.Notifications.taskDidExitNotification(task.activityType))
            return
        }

        NSNotificationCenter.defaultCenter().postNotification(NSTask.Notifications.taskDErrorNotification(task.activityType))
    }
    
    /**

    /**
    
    Adds the given *project* to the list of projects.
    
    If #delegate is set, you will receive a callback to WindmillDelegate#windmillself, projects:self.projects, addedProject project: project)
    if the project was

    - precondition: the given *project* must have a valid remote origin
    
    - parameter project: the project to add to Windmill
    - returns: true if the 'project' was added, false if already added
    */

    project was added
    project not be added
    project failed to create
    
    */
    func create(project: Project) -> Bool
    {
        guard !self.projects.contains(project) else {
            Windmill.logger.log(.INFO, "Project already added: \(project)")
            return false
        }
        
        self.add(project)
        self.delegate?.windmill(self, projects:self.projects, addedProject: project)
        self.deploy(project)
        self.monitor(project)
        
        return true
    }
    
    func start(){
        for project in self.projects {
            self.deploy(project)
            self.monitor(project)
        }
    }
}