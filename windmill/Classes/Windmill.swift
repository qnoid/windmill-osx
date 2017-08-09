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
protocol WindmillError: Error {
    
}

typealias Domain = String

let WindmillDomain : Domain = "io.windmill"

final class Windmill: SchedulerDelegate
{
    class func windmill(_ keychain: Keychain) -> Windmill
    {
        let projects = InputStream.inputStreamOnProjects().read()
        
        os_log("%{public}@", log: .default, type: .debug, projects)
        
        let windmill = Windmill(keychain: keychain)
        windmill.projects = projects
        
        return windmill
    }
    
    let dispatch_queue_serial = DispatchQueue(label: "io.windmil.process.output", qos: .utility, attributes: [])
    
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

    private func poll(_ project: Project, ifCaseOfBranchBehindOrigin callback: @escaping () -> Void) {
        
        #if DEBUG
            let delayInSeconds:Int = 5
        #else
            let delayInSeconds:Int = 30
        #endif

        self.scheduler.queue(process: Process.makePoll(project.name), type: .poll, delayInSeconds: delayInSeconds) { [weak self] success, error in
            
            if let error = (error as NSError?), error.code == 255 {
                callback()
                return
            }
            
            self?.poll(project, ifCaseOfBranchBehindOrigin: callback)
        }
    }
    
    private func monitor(_ project: Project) {
        self.poll(project, ifCaseOfBranchBehindOrigin: {
            self.deploy(project) {
                self.monitor(project)
            }
        })
    }
    
    private func deploy(_ project: Project, success completionHandler: @escaping () -> Void)
    {
        guard let user = try? self.keychain.findWindmillUser() else {
            os_log("A windmill user account should have been created.", log: .default, type: .error)
            return
        }
        
        self.delegate?.windmill(self, willDeployProject: project)
        
        let name = project.name

        let directoryPath = "\(FileManager.default.windmill)\(name)"
        os_log("%{public}@", log: .default, type: .debug, directoryPath)
        
        let forwardExecution = ForwardExecution(execute: scheduler.makeExecute(Process.makeCheckout(name, origin: project.origin), type: .checkout) )
            .then( scheduler.makeExecute(Process.makeBuild(directoryPath: directoryPath, scheme: project.scheme), type: .build) )
            .then( scheduler.makeExecute(Process.makeTest(directoryPath: directoryPath, scheme: project.scheme), type: .test))
            .then( scheduler.makeExecute(Process.makeArchive(directoryPath: directoryPath, scheme: project.scheme, projectName: name), type: .archive))
            .then( scheduler.makeExecute(Process.makeExport(directoryPath: directoryPath, projectName: name), type: .export))
            .then( scheduler.makeExecute(Process.makeDeploy(directoryPath: directoryPath, scheme: project.scheme, forUser: user), type: .deploy))

        scheduler.queue(execute: forwardExecution.dispatchWorkItem { success, error in
            
            guard success else {
                if let error = (error as NSError?), let type = error.userInfo["type"] as? ActivityType {
                    
                    let notification = Process.Notifications.makeErrorNotification(type)
                    NotificationCenter.default.post(notification)
                }
                return
            }
            
            completionHandler()
        })
    }
    
    func didReceive(process: Process, type: ActivityType, standardOutput: String, count: Int) {
        let log = OSLog(subsystem: "io.windmill.windmill", category: type.rawValue)
        os_log("%{public}@", log: log, type: .debug, standardOutput)
        self.delegate?.windmill(self, standardOutput: standardOutput, count: count)
    }
    
    func didReceive(process: Process, type: ActivityType, standardError: String, count: Int) {
        let log = OSLog(subsystem: "io.windmill.windmill", category: type.rawValue)
        os_log("%{public}@", log: log, type: .error, standardError)
        self.delegate?.windmill(self, standardError: standardError, count: count)
    }
    
    func willLaunch(process: Process, type: ActivityType, scheduler: Scheduler) {
        waitForStandardOutputInBackground(process: process, queue: dispatch_queue_serial, type: type)
        waitForStandardErrorInBackground(process: process, queue: dispatch_queue_serial, type: type)
    }
    
    func didLaunch(process: Process, type: ActivityType, scheduler: Scheduler) {
        NotificationCenter.default.post(Process.Notifications.makeDidLaunchNotification(type))
    }
    
    func didExitSuccesfully(process: Process, type: ActivityType, scheduler: Scheduler) {
        NotificationCenter.default.post(Process.Notifications.makeDidExitSuccesfullyNotification(type))
    }
    
    /**

    /**
    
    Adds the given *project* to the list of projects.
    
    If #delegate is set, you will receive a callback to WindmillDelegate#windmillself, projects:self.projects, addedProject project: project)
    if the project was added.

    - precondition: the given *project* must have a valid remote origin
    
    - parameter project: the project to add to Windmill
    - returns: true if the 'project' was added, false if already added.
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
        self.deploy(project) {
            self.monitor(project)
        }
        
        return true
    }
    
    func start() -> Bool {
        for project in self.projects {
            self.deploy(project) {
                self.monitor(project)
            }
        }
        
        return self.projects.count > 0
    }
}
