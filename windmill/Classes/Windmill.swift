//
//  Windmill.swift
//  windmill
//
//  Created by Markos Charatzas on 13/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation
import ObjectiveGit
import os


typealias WindmillProvider = () -> Windmill

/// domain is WindmillDomain. code: WindmillErrorCode(s), has its userInfo set with NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey and NSUnderlyingErrorKey set
protocol WindmillError: TaskError {
    
}

typealias Domain = String

let WindmillDomain : Domain = "io.windmill"

final class Windmill: SchedulerDelegate, ActivityTaskDelegate
{
    static var dispatch_queue_serial = DispatchQueue(label: "io.windmil.queue", attributes: [])
    
    static func dispatch_after(_ seconds: Int, queue: DispatchQueue = dispatch_queue_serial, block: @escaping ()->()) {
        queue.asyncAfter(deadline: DispatchTime.now() + .seconds(seconds), execute: block)
    }

    class func windmill(_ keychain: Keychain) -> Windmill
    {
        let projects = InputStream.inputStreamOnProjects().read()
        
        os_log("%{public}@", log: .default, type: .debug, projects)
        
        let windmill = Windmill(keychain: keychain)
        windmill.projects = projects
        
        return windmill
    }
    
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
    
    private func add(_ project: Project)
    {
        self.projects.append(project)
        
        OutputStream.outputStreamOnProjects().write(self.projects)
    }

    private func poll(_ project: Project, ifCaseOfBranchBehindOrigin callback: @escaping ()->()) {
        
        self.scheduler.schedule(queue: Windmill.dispatch_queue_serial, task: Process.taskPoll(project.name)) { [weak self] task, error in
            if let error = error as? PollTaskError, case .branchBehindOrigin = error {
                callback()
                return
            }
            
            self?.poll(project, ifCaseOfBranchBehindOrigin: callback)
        }
    }
    
    private func monitor(_ project: Project) {
        self.poll(project, ifCaseOfBranchBehindOrigin: {
            self.deploy(project)
            self.monitor(project)
        })
    }
    
    private func deploy(_ project: Project)
    {
        guard let user = try? self.keychain.findWindmillUser() else {
            os_log("%{public}@", log: .default, type: .error, "A windmill user account should have been created.")
            return
        }
        
        self.delegate?.windmill(self, willDeployProject: project)
        
        let name = project.name

        let directoryPath = "\(FileManager.default.windmill)\(name)"
        os_log("%{public}@", log: .default, type: .debug, directoryPath)
        
        self.scheduler.queue(queue: Windmill.dispatch_queue_serial, tasks: Process.taskCheckout(name, origin: project.origin),
            Process.taskBuild(directoryPath: directoryPath, scheme: project.scheme),
            Process.taskTest(directoryPath: directoryPath, scheme: project.scheme),
            Process.taskArchive(directoryPath: directoryPath, scheme: project.scheme, projectName: name),
            Process.taskExport(directoryPath: directoryPath, projectName: name),
            Process.taskDeploy(directoryPath: directoryPath, projectName: name, forUser: user))
    }
    
    func willLaunch(_ task: ActivityTask, scheduler: Scheduler) {
        var task = task
        task.delegate = self
        task.waitForStandardOutputInBackground()
        task.waitForStandardErrorInBackground()
    }
    
    func didReceive(_ task: ActivityTask, standardOutput: String, count: Int) {
        let log = OSLog(subsystem: "io.windmill.windmill", category: task.activityType.rawValue)
        os_log("%{public}@", log: log, type: .debug, standardOutput)
        self.delegate?.windmill(self, standardOutput: standardOutput, count: count)
    }
    
    func didReceive(_ task: ActivityTask, standardError: String, count: Int) {
        let log = OSLog(subsystem: "io.windmill.windmill", category: task.activityType.rawValue)
        os_log("%{public}@", log: log, type: .error, standardError)
        self.delegate?.windmill(self, standardError: standardError, count: count)
    }
    
    func didLaunch(_ task: ActivityTask, scheduler: Scheduler) {
    
        NotificationCenter.default.post(Process.Notifications.taskDidLaunchNotification(task.activityType))
    }
    
    func didExit(_ task: ActivityTask, error: Error?, scheduler: Scheduler) {
        
        guard case .succesful = task.status else {
            NotificationCenter.default.post(Process.Notifications.taskDErrorNotification(task.activityType))
        return
        }
        
        NotificationCenter.default.post(Process.Notifications.taskDidExitNotification(task.activityType))
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
    func create(_ project: Project) -> Bool
    {
        guard !self.projects.contains(project) else {
            os_log("%{public}@", log: .default, type: .info, "Project already added: \(project)")
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
