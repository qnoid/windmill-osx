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

/* final */ class Windmill: ProcessManagerDelegate
{
    struct Notifications {
        static let willDeployProject = Notification.Name("WindmillWillDeployProject")
    }
    
    class func windmill(_ keychain: Keychain) -> Windmill
    {
        let projects = InputStream.inputStreamOnProjects().read()
        
        os_log("%{public}@", log: .default, type: .debug, projects)
        
        let windmill = Windmill(keychain: keychain)
        windmill.projects = projects
        
        return windmill
    }
    
    let dispatch_queue_serial = DispatchQueue(label: "io.windmil.process.output", qos: .utility, attributes: [])
    
    let notificationCenter = NotificationCenter.default
    var delegate: WindmillDelegate?
    
    let keychain: Keychain
    var processManager: ProcessManager
    
    var projects : Array<Project>
    
    convenience init()
    {
        self.init(keychain: Keychain.defaultKeychain())
    }
    
    init(keychain: Keychain, processManager: ProcessManager = ProcessManager())
    {

        self.keychain = keychain
        self.processManager = processManager
        self.projects = []
        self.processManager.delegate = self
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
        
        let poll = self.processManager.makeDispatchWorkItem(process: Process.makePoll(project.name), type: .poll) { [weak self] type, success, error in
            if let error = (error as NSError?), error.code == 255 {
                callback()
                return
            }
            
            self?.poll(project, ifCaseOfBranchBehindOrigin: callback)
            
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(delayInSeconds), execute: poll)
    }
    
    private func monitor(_ project: Project) {
        self.poll(project, ifCaseOfBranchBehindOrigin: {
            self.deploy(project: project) {_,_,_ in
                self.monitor(project)
            }
        })
    }
    
    /* fileprivate */ func deploy(project: Project, at directoryPath: String, for user: String, completionHandler: @escaping ProcessCompletionHandler)
    {
        self.notificationCenter.post(name: Windmill.Notifications.willDeployProject, object: project, userInfo: ["directoryPath":directoryPath, "user":user])
        
        let didComplete: ProcessCompletionHandler = { type, success, error in
            self.didComplete(type: type, success: success, error: error)
        }

        let deploy: ProcessCompletionHandler = { type, success, error in
            let deploy = self.processManager.makeDispatchWorkItem(process: Process.makeDeploy(directoryPath: directoryPath, scheme: project.scheme, forUser: user), type: .deploy, completionHandler: ProcessCompletionHandlerChain(completionHandler: didComplete).case(success: completionHandler))
            
            deploy.perform()
        }

        let export: ProcessCompletionHandler = { type, success, error in
            let export = self.processManager.makeDispatchWorkItem(process: Process.makeExport(directoryPath: directoryPath, projectName: project.name), type: .export, completionHandler: ProcessCompletionHandlerChain(completionHandler: didComplete).case(success: deploy))
            
            export.perform()
        }
        
        let archive: ProcessCompletionHandler = { type, success, error in
            let archive = self.processManager.makeDispatchWorkItem(process: Process.makeArchive(directoryPath: directoryPath, scheme: project.scheme, projectName: project.name), type: .archive, completionHandler: ProcessCompletionHandlerChain(completionHandler: didComplete).case(success: export))
            
            archive.perform()
        }

        let test: ProcessCompletionHandler = { type, success, error in
            let test = self.processManager.makeDispatchWorkItem(process: Process.makeTest(directoryPath: directoryPath, scheme: project.scheme), type: .test, completionHandler: ProcessCompletionHandlerChain(completionHandler: didComplete).case(success: archive))
            
            test.perform()
        }

        let build: ProcessCompletionHandler = { type, success, error in
            let build = self.processManager.makeDispatchWorkItem(process: Process.makeBuild(directoryPath: directoryPath, scheme: project.scheme), type: .build, completionHandler: ProcessCompletionHandlerChain(completionHandler: didComplete).case(success: test))
            
            build.perform()
        }
        
        let checkout = self.processManager.makeDispatchWorkItem(
            process: Process.makeCheckout(directoryPath: directoryPath, repoName: project.name, origin: project.origin),
            type: .checkout,
            completionHandler: ProcessCompletionHandlerChain(completionHandler: didComplete).case(success: build))
        
        checkout.perform()

    }
    
    /* fileprivate */ func deploy(project: Project, at directoryPath: String, completionHandler: @escaping ProcessCompletionHandler) {
        
        guard let user = try? self.keychain.findWindmillUser() else {
            os_log("A windmill user account should have been created.", log: .default, type: .error)
            return
        }
        
        self.deploy(project: project, at: directoryPath, for: user, completionHandler: completionHandler)
    }
    
    /* fileprivate */ func deploy(project: Project, for user: String, completionHandler: @escaping ProcessCompletionHandler) {
        
        let directoryPath = "\(FileManager.default.windmill)\(project.name)"
        os_log("%{public}@", log: .default, type: .debug, directoryPath)
        
        self.deploy(project: project, at: directoryPath, for: user, completionHandler: completionHandler)
    }
    
    /* fileprivate */ func deploy(project: Project, completionHandler: @escaping ProcessCompletionHandler) {
        
        guard let user = try? self.keychain.findWindmillUser() else {
            os_log("A windmill user account should have been created.", log: .default, type: .error)
            return
        }
        
        self.deploy(project: project, for: user, completionHandler: completionHandler)
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
    
    func willLaunch(manager: ProcessManager, process: Process, type: ActivityType) {
        waitForStandardOutputInBackground(process: process, queue: dispatch_queue_serial, type: type)
        waitForStandardErrorInBackground(process: process, queue: dispatch_queue_serial, type: type)
    }
    
    func didLaunch(manager: ProcessManager, process: Process, type: ActivityType) {
        NotificationCenter.default.post(Process.Notifications.makeDidLaunchNotification(type))
    }
    
    func didComplete(type: ActivityType, success: Bool, error: Error?) {
        
        guard success else {
            if let error = (error as NSError?), let type = error.userInfo["type"] as? ActivityType {
                let notification = Process.Notifications.makeErrorNotification(type)
                NotificationCenter.default.post(notification)
            } else {
                os_log("Error does not hold an ActivityType for its 'type' key. Double check what instance 'type' is.", log: .default, type: .error)
            }
            return
        }
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
    @discardableResult func create(_ project: Project) -> Bool
    {
        guard !self.projects.contains(project) else {
            os_log("%{public}@", log: .default, type: .info, "Project already added: \(project)")
            return false
        }
        
        self.add(project)
        self.deploy(project: project) {_,_,_ in
            self.monitor(project)
        }
        
        return true
    }
    
    @discardableResult func start() -> Bool {
        for project in self.projects {
            self.deploy(project: project) {_,_,_ in
                self.monitor(project)
            }
        }
        
        return self.projects.count > 0
    }
}
