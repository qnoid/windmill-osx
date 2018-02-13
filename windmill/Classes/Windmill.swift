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

let WindmillErrorDomain : String = "io.windmill"

/* final */ class Windmill: ProcessMonitor
{
    class func make(project: Project, user: String? = try? Keychain.defaultKeychain().findWindmillUser()) -> (windmill: Windmill, sequence: Sequence) {

        let processManager = ProcessManager()
        let windmill = Windmill(processManager: processManager, project: project)

        guard let user = user else {
            let repeatableExport = windmill.repeatableExport()
            return (windmill: windmill, sequence: repeatableExport)
        }

        let repeatableDeploy = windmill.repeatableDeploy(user: user)        
        return (windmill: windmill, sequence: repeatableDeploy)
    }
    
    struct Notifications {
        static let willStartProject = Notification.Name("will.start")
        static let didArchiveProject = Notification.Name("did.archive")
        static let didExportProject = Notification.Name("did.export")
        static let didDeployProject = Notification.Name("did.deploy")
        static let willMonitorProject = Notification.Name("will.monitor")
        
        static let activityDidLaunch = Notification.Name("activity.did.launch")
        static let activityDidExitSuccesfully = Notification.Name("activity.did.exit.succesfully")
        static let activityError = Notification.Name("activity.error")
    }
    
    let log = OSLog(subsystem: "io.windmill.windmill", category: "windmill")
    let notificationCenter = NotificationCenter.default
    var delegate: WindmillDelegate?
    
    let project: Project
    let processManager: ProcessManager

    // MARK: init
    
    public convenience init(project: Project) {
        self.init(processManager: ProcessManager(), project: project)
    }
    
    init(processManager: ProcessManager, project: Project)
    {
        self.project = project
        self.processManager = processManager
        self.processManager.monitor = self
    }
    
    // MARK: private
    
    /* private */ func exportSequence(for project: Project, exportWasSuccesful: DispatchWorkItem? = nil) -> Sequence {
        let directoryPath = project.directoryPathURL.path
        let checkout = Process.makeCheckout(repoName: project.name, origin: project.origin)
        
        return self.processManager.sequence(process:checkout, userInfo: ["activity" : ActivityType.checkout], wasSuccesful: DispatchWorkItem { [weak self] in
            let buildSettings = BuildSettings.make(for: project)
            let readBuildSettings = Process.makeReadBuildSettings(directoryPath: directoryPath, forProject: project, buildSettings: buildSettings)
            self?.processManager.sequence(process: readBuildSettings, userInfo: ["activity" : ActivityType.showBuildSettings], wasSuccesful: DispatchWorkItem {
                let devices = Devices.make(for: project)
                let readDevices = Process.makeReadDevices(directoryPath: directoryPath, forProject: project, devices: devices, buildSettings: buildSettings)
                self?.processManager.sequence(process: readDevices, userInfo: ["activity" : ActivityType.devices], wasSuccesful: DispatchWorkItem {
                    let build = Process.makeBuild(directoryPath: directoryPath, project: project, devices: devices)
                    self?.processManager.sequence(process: build, userInfo: ["activity" : ActivityType.build], wasSuccesful: DispatchWorkItem {
                        let test = Process.makeTest(directoryPath: directoryPath, project: project, devices: devices)
                        self?.processManager.sequence(process: test, userInfo: ["activity" : ActivityType.test], wasSuccesful: DispatchWorkItem {
                            let archive = Process.makeArchive(directoryPath: directoryPath, project: project)
                            self?.processManager.sequence(process: archive, userInfo: ["activity" : ActivityType.archive], wasSuccesful: DispatchWorkItem {
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: Windmill.Notifications.didArchiveProject, object: self, userInfo: ["project":project])
                                }
                                let export = Process.makeExport(directoryPath: directoryPath, project: project)
                                self?.processManager.sequence(process: export, userInfo: ["activity" : ActivityType.export], wasSuccesful: exportWasSuccesful).launch()
                            }).launch()
                        }).launch()
                    }).launch()
                }).launch()
            }).launch()
        })
    }
    
    /* fileprivate */ func repeatableDeploy(user: String) -> Sequence {
        let directoryPath = project.directoryPathURL.path
        
        let exportWasSuccesful = DispatchWorkItem { [project = self.project, weak self] in
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Windmill.Notifications.didExportProject, object: self, userInfo: ["project":project])
            }
            
            let deploy = Process.makeDeploy(directoryPath: directoryPath, project: project, forUser: user)
            self?.processManager.sequence(process: deploy, userInfo: ["activity" : ActivityType.deploy], wasSuccesful: DispatchWorkItem {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Windmill.Notifications.didDeployProject, object: self, userInfo: ["project":project])
                }
                
                #if DEBUG
                    let delayInSeconds:Int = 5
                #else
                    let delayInSeconds:Int = 30
                #endif
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Windmill.Notifications.willMonitorProject, object: self, userInfo: ["project":project])
                }

                let log = OSLog(subsystem: "io.windmill.windmill", category: "windmill")
                os_log("will start monitoring", log: log, type: .debug)

                self?.processManager.repeat(process: Process.makePoll(directoryPath: directoryPath, project: project), every: .seconds(delayInSeconds), until: 1, then: DispatchWorkItem {
                    self?.notificationCenter.post(name: Windmill.Notifications.willStartProject, object: self, userInfo: ["project":project])
                    self?.repeatableDeploy(user: user).launch()
                })
            }).launch()
        }
        
        return self.exportSequence(for: project, exportWasSuccesful: exportWasSuccesful)
    }
    
    /* fileprivate */ func repeatableExport() -> Sequence {
        let directoryPath = project.directoryPathURL.path

        let exportWasSuccesful = DispatchWorkItem { [project = self.project, weak self] in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Windmill.Notifications.didExportProject, object: self, userInfo: ["project":project])
            }
            
            #if DEBUG
                let delayInSeconds:Int = 5
            #else
                let delayInSeconds:Int = 30
            #endif

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Windmill.Notifications.willMonitorProject, object: self, userInfo: ["project":project])
            }

            let log = OSLog(subsystem: "io.windmill.windmill", category: "windmill")
            os_log("will start monitoring", log: log, type: .debug)

            self?.processManager.repeat(process: Process.makePoll(directoryPath: directoryPath, project: project), every: .seconds(delayInSeconds), until: 1, then: DispatchWorkItem {
                self?.notificationCenter.post(name: Windmill.Notifications.willStartProject, object: self, userInfo: ["project":project])
                self?.repeatableExport().launch()
            })
        }
        
        return self.exportSequence(for: project, exportWasSuccesful: exportWasSuccesful)
    }
    
    // MARK: public
    
    func run(sequence: Sequence)
    {
        self.notificationCenter.post(name: Windmill.Notifications.willStartProject, object: self, userInfo: ["project":self.project])
        
        sequence.launch()
    }
    
    // MARK: ProcessMonitor
    func willLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?) {

    }
    
    func didLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?) {
        
        guard let activity = userInfo?["activity"] as? ActivityType else {
            return
        }
        
        os_log("activity did launch `%{public}@`", log: log, type: .debug, activity.rawValue)

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notifications.activityDidLaunch, object: self, userInfo: userInfo)
        }
    }
    
    func didExit(manager: ProcessManager, process: Process, isSuccess: Bool, userInfo: [AnyHashable : Any]?) {
        
        guard let activity = userInfo?["activity"] as? ActivityType else {
            return
        }
        
        guard isSuccess else {
            let error: NSError = NSError.errorTermination(process: process, for: activity, status: process.terminationStatus)
            
            let log = OSLog(subsystem: "io.windmill.windmill", category: "windmill")
            os_log("activity '%{public}@' did error: %{public}@", log: log, type: .error, error)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notifications.activityError, object: self, userInfo: ["error": error, "activity": activity])
            }
            return
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notifications.activityDidExitSuccesfully, object: self, userInfo: userInfo)
        }
    }
}
