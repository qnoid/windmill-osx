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

/// domain is WindmillErrorDomain. code: WindmillErrorCode(s), has its userInfo set with NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey and NSUnderlyingErrorKey set
protocol WindmillError: Error {
    
}

let WindmillErrorDomain : String = "io.windmill"

/* final */ class Windmill: ProcessManagerDelegate
{
    struct Notifications {
        static let willDeployProject = Notification.Name("WindmillWillDeployProject")
        static let didArchiveProject = Notification.Name("didArchiveProject")
        static let didExportProject = Notification.Name("export")
        static let didDeployProject = Notification.Name("deploy")
        static let activityDidLaunch = Notification.Name("activityDidLaunch")
        static let activityDidExitSuccesfully = Notification.Name("activityDidExitSuccesfully")
        static let activityError = Notification.Name("activityError")
    }
    
    class func windmill(_ keychain: Keychain) -> Windmill {
        return Windmill(keychain: keychain)
    }
    
    let dispatch_queue_serial = DispatchQueue(label: "io.windmil.process.output", qos: .utility, attributes: [])
    
    let notificationCenter = NotificationCenter.default
    var delegate: WindmillDelegate?
    
    let keychain: Keychain
    var processManager: ProcessManager
    
    convenience init()
    {
        self.init(keychain: Keychain.defaultKeychain())
    }
    
    init(keychain: Keychain, processManager: ProcessManager = ProcessManager())
    {

        self.keychain = keychain
        self.processManager = processManager
        self.processManager.delegate = self
    }
    
    private func poll(_ project: Project, deadline:DispatchTime = DispatchTime.now(), ifCaseOfBranchBehindOrigin callback: @escaping () -> Void) {
        
        let poll = self.processManager.makeDispatchWorkItem(process: Process.makePoll(directoryPath: project.directoryPathURL.path, project: project), type: .poll) { [weak self] process, type, success, error in
            if let error = (error as NSError?), error.code == 1 {
                callback()
                return
            }

            #if DEBUG
                let delayInSeconds:Int = 5
            #else
                let delayInSeconds:Int = 30
            #endif            

            self?.poll(project, deadline: DispatchTime.now() + .seconds(delayInSeconds),  ifCaseOfBranchBehindOrigin: callback)
            
        }
        DispatchQueue.main.asyncAfter(deadline: deadline, execute: poll)
    }
    
    private func monitor(_ project: Project) {
        self.poll(project, ifCaseOfBranchBehindOrigin: { [weak self] in
            self?.deploy(project: project) {_, _,_,_ in
                self?.monitor(project)
            }
        })
    }
    
    /* fileprivate */ func deploy(project: Project, at directoryPath: String, for user: String, completionHandler: @escaping ProcessCompletionHandler)
    {
        self.notificationCenter.post(name: Windmill.Notifications.willDeployProject, object: self, userInfo: ["directoryPath":directoryPath, "user":user, "project":project])
        
        let checkout = self.processManager.makeCompute(process: Process.makeCheckout(repoName: project.name, origin: project.origin),type: .checkout)
        
        let buildMetadata = MetadataJSONEncoded.buildMetadata(for: project)
        let build = self.processManager.makeCompute(process: Process.makeBuild(directoryPath: directoryPath, project: project, metadata: buildMetadata), type: .build)
        
        let metadata = MetadataJSONEncoded.testMetadata(for: project)
        let readTestMetadata = self.processManager.makeCompute(process: Process.makeReadTestMetadata(directoryPath: directoryPath, forProject: project, metadata: metadata, buildMetadata: buildMetadata), type: .undefined)
        let test = self.processManager.makeCompute(process: Process.makeTest(directoryPath: directoryPath, scheme: project.scheme, metadata: metadata), type: .test)
        
        let archive = self.processManager.makeCompute(process: Process.makeArchive(directoryPath: project.directoryPathURL.path, project: project), type: .archive)
        let export = self.processManager.makeCompute(process: Process.makeExport(directoryPath: directoryPath, project: project), type: .export)
        let deploy = self.processManager.makeCompute(process: Process.makeDeploy(directoryPath: directoryPath, project: project, forUser: user), type: .deploy)

        let alwaysChain = ProcessCompletionHandlerChain { [weak self] (process, type, isSuccess, error) in
            self?.didComplete(type: type, success: isSuccess, error: error)
        }
        
        checkout.dispatchWorkItem(DispatchQueue.main, alwaysChain.success { [weak self] (process, type, isSuccess, error) in
            build.dispatchWorkItem(DispatchQueue.main, alwaysChain.success { (process, type, isSuccess, error) in
                readTestMetadata.dispatchWorkItem(DispatchQueue.main, { (process, type, isSuccess, error) in
                    test.dispatchWorkItem(DispatchQueue.main, alwaysChain.success { (process, type, isSuccess, error) in
                        archive.dispatchWorkItem(DispatchQueue.main, alwaysChain.success { (process, type, isSuccess, error) in
                            self?.didArchive(project: project)
                            export.dispatchWorkItem(DispatchQueue.main, alwaysChain.success { (process, type, isSuccess, error) in
                                self?.didExport(project: project)
                                deploy.dispatchWorkItem(DispatchQueue.main, alwaysChain.success{ (process, type, isSuccess, error) in
                                    self?.didDeploy(project: project)
                                    completionHandler(process, type, isSuccess, error)
                                }).perform()
                            }).perform()
                        }).perform()
                    }).perform()
                }).perform()
            }).perform()
        }).perform()
    }
    
    /* fileprivate */ func deploy(project: Project, at directoryPath: String, completionHandler: @escaping ProcessCompletionHandler) {
        
        guard let user = try? self.keychain.findWindmillUser() else {
            os_log("A windmill user account should have been created.", log: .default, type: .error)
            return
        }
        
        self.deploy(project: project, at: directoryPath, for: user, completionHandler: completionHandler)
    }
    
    /* fileprivate */ func deploy(project: Project, for user: String, completionHandler: @escaping ProcessCompletionHandler) {
        
        let directoryPath = project.directoryPathURL.path
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
        os_log("%{public}@", log: log, type: .debug, standardError)
        self.delegate?.windmill(self, standardError: standardError, count: count)
    }
    
    func willLaunch(manager: ProcessManager, process: Process, type: ActivityType) {
        if case .undefined = type {
            return
        }

        waitForStandardOutputInBackground(process: process, queue: dispatch_queue_serial, type: type)
        waitForStandardErrorInBackground(process: process, queue: dispatch_queue_serial, type: type)
    }
    
    func didLaunch(manager: ProcessManager, process: Process, type: ActivityType) {
        if case .undefined = type {
            return
        }
        
        let log = OSLog(subsystem: "io.windmill.windmill", category: type.rawValue)
        os_log("did launch `%{public}@`", log: log, type: .debug, type.description)

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notifications.activityDidLaunch, object: self, userInfo: ["activity":type.rawValue])
        }
    }
    
    func didComplete(type: ActivityType, success: Bool, error: Error?) {
        
        guard success else {
            if let error = error as NSError? {
                let log = OSLog(subsystem: "io.windmill.windmill", category: type.rawValue)
                os_log("%{public}@", log: log, type: .error, error)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notifications.activityError, object: self, userInfo: ["error": error, "activity": type])
                }
            }

            return
        }
        let log = OSLog(subsystem: "io.windmill.windmill", category: type.rawValue)
        os_log("did complete successfully `%{public}@`", log: log, type: .debug, type.description)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notifications.activityDidExitSuccesfully, object: self, userInfo: ["activity":type.rawValue])
        }
    }
    
    func didArchive(project: Project) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notifications.didArchiveProject, object: self, userInfo: ["project":project])
        }
    }

    func didExport(project: Project) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notifications.didExportProject, object: self, userInfo: ["project":project])
        }
    }

    func didDeploy(project: Project) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notifications.didDeployProject, object: self, userInfo: ["project":project])
        }
    }

    /**
     
     /**
     
     Attempt to deploy and monitor the given *project*.
     
     If #delegate is set, you will receive a callback to WindmillDelegate#windmillself, projects:self.projects, addedProject project: project)
     if the project was added.
     
     - precondition: the given *project* must have a valid remote origin
     
     - parameter project: the project to deploy to Windmill
     */
     
     project was added
     project not be added
     project failed to create
     
     */
    func start(_ project: Project)
    {
        self.deploy(project: project) {[weak self] _, _,_,_ in
            self?.monitor(project)
        }
    }
}
