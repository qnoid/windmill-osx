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
let XcodeBuildErrorDomain : String = "com.xcode.xcodebuild"

public struct WindmillStringKey : RawRepresentable, Equatable, Hashable {

    enum Test: String {
        case nothing
    }
    
    public static let test: WindmillStringKey = WindmillStringKey(rawValue: "io.windmill.windmill.key.test")!
    
    public static func ==(lhs: WindmillStringKey, rhs: WindmillStringKey) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    public typealias RawValue = String
    
    public var hashValue: Int {
        return self.rawValue.hashValue
    }
    
    public var rawValue: String
    
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

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
        static let didBuildProject = Notification.Name("did.build")
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
    
    let applicationCachesDirectory = Directory.Windmill.ApplicationCachesDirectory()
    let applicationSupportDirectory = Directory.Windmill.ApplicationSupportDirectory()

    lazy var projectHomeDirectory: ProjectHomeDirectory = FileManager.default.windmillHomeDirectory.projectHomeDirectory(at: project.name)
    lazy var projectSourceDirectory: ProjectSourceDirectory = applicationCachesDirectory.projectSourceDirectory(at: project.name)
    
    //
    var project: Project
    let processManager: ProcessManager
    
    var delegate: WindmillDelegate?
    

    // MARK: init
    
    public convenience init(project: Project) {
        self.init(processManager: ProcessManager(), project: project)
    }
    
    init(processManager: ProcessManager, project: Project) {

        self.project = project
        self.processManager = processManager
        self.processManager.monitor = self
    }
    
    private func build(scheme: String, destination: Devices.Destination, wasSuccesful: ProcessWasSuccesful) {
        
        self.build(scheme: scheme, destination: destination, repositoryLocalURL: projectSourceDirectory.URL, derivedDataURL: applicationCachesDirectory.derivedDataURL(at: project.name), resultBundle: applicationSupportDirectory.buildResultBundle(at: project.name), wasSuccesful: wasSuccesful)
    }
    
    private func didBuild(project: Project, using buildSettings: BuildSettings, appBundle: AppBundle, destination: Devices.Destination) {
        let directory = self.projectHomeDirectory

        let appBundleBuilt = appBundle
        let appBundle = directory.appBundle(name: buildSettings.product.name ?? project.name)
        try? FileManager.default.copyItem(at: appBundleBuilt.url, to: appBundle.url)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Windmill.Notifications.didBuildProject, object: self, userInfo: ["project":project, "appBundle": appBundle, "destination": destination])
        }
        
    }
    private func didReadDevices(devices: Devices) {
        guard let destination = devices.destination else {
            os_log("Destination couldn't not be read from devices at '%{public}@'. Is a 'devices.json' present? Does it define a 'destination' dictionary?`", log: log, type: .debug, devices.url.path)
            return
        }
        Process.makeBoot(destination: destination).launch()
    }

    // MARK: private
    
    /* private */ func exportSequence(exportWasSuccesful: ProcessWasSuccesful? = nil) -> Sequence {
        
        let directory = self.projectHomeDirectory
        let repositoryLocalURL = projectSourceDirectory.URL
        let checkout = Process.makeCheckout(sourceDirectory: projectSourceDirectory, project: self.project)
        let derivedDataURL = applicationCachesDirectory.derivedDataURL(at: project.name)
        let applicationSupportDirectory = self.applicationSupportDirectory
        
        
        return self.processManager.sequence(process:checkout, userInfo: ["activity" : ActivityType.checkout, "repositoryLocalURL": repositoryLocalURL], wasSuccesful: ProcessWasSuccesful { [project = self.project, configuration = directory.configuration(), weak self] userInfo in
            let readProjectConfiguration = Process.makeReadProjectConfiguration(repositoryLocalURL: repositoryLocalURL, projectConfiguration: configuration)
            self?.processManager.sequence(process: readProjectConfiguration, userInfo: ["activity": ActivityType.readProjectConfiguration, "configuration": configuration], wasSuccesful: ProcessWasSuccesful { [buildSettings = directory.buildSettings()] userInfo in
                
                let scheme = configuration.detectScheme(name: project.scheme)
                let readBuildSettings = Process.makeReadBuildSettings(repositoryLocalURL: repositoryLocalURL, scheme: scheme, buildSettings: buildSettings)
                self?.processManager.sequence(process: readBuildSettings, userInfo: ["activity" : ActivityType.showBuildSettings], wasSuccesful: ProcessWasSuccesful { [devices = directory.devices(), buildSettings = directory.buildSettings()] userInfo in
                    let readDevices = Process.makeReadDevices(repositoryLocalURL: repositoryLocalURL, scheme: scheme, devices: devices, buildSettings: buildSettings)
                    self?.processManager.sequence(process: readDevices, userInfo: ["activity" : ActivityType.devices, "devices": devices], wasSuccesful: ProcessWasSuccesful { userInfo in
                        
                        self?.didReadDevices(devices: devices)

                        let appBundle = directory.appBundle(name: buildSettings.product.name ?? project.name)
                        try? FileManager.default.removeItem(at: appBundle.url)
                        
                        guard let destination = devices.destination else {
                            if let log = self?.log {
                                os_log("Destination couldn't not be read from devices at '%{public}@'. Is a 'devices.json' present? Does it define a '' dictionary?`", log: log, type: .debug, devices.url.path)
                            }
                            return
                        }

                        self?.build(scheme: scheme, destination: destination, wasSuccesful: ProcessWasSuccesful { [destination = destination, devices = devices] buildInfo in

                            let appBundle = directory.appBundle(derivedDataURL: derivedDataURL, name: buildSettings.product.name ?? project.name)
                            self?.didBuild(project: project, using: buildSettings, appBundle: appBundle, destination: destination)

                            let test: Process
                            let userInfo: [AnyHashable: Any]
                            let testResultBundle = applicationSupportDirectory.testResultBundle(at: project.name)
                            
                            if WindmillStringKey.Test.nothing == (buildInfo?[WindmillStringKey.test] as? WindmillStringKey.Test) {
                                userInfo = ["activity" : ActivityType.test]
                                test = Process.makeTestSkip(repositoryLocalURL: repositoryLocalURL, scheme: scheme, destination: destination, derivedDataURL: derivedDataURL, resultBundle: testResultBundle)
                            } else {
                                userInfo = ["activity" : ActivityType.test, "devices": devices, "destination": destination]
                                test = Process.makeTestWithoutBuilding(repositoryLocalURL: repositoryLocalURL, scheme: scheme, destination: destination, derivedDataURL: derivedDataURL, resultBundle: testResultBundle)
                            }
                            
                            self?.processManager.sequence(process: test, userInfo: userInfo, wasSuccesful: ProcessWasSuccesful { userInfo in

                                let archive: Archive = directory.archive(name: scheme)
                                let archiveResultBundle = applicationSupportDirectory.archiveResultBundle(at: project.name)
                                let makeArchive = Process.makeArchive(repositoryLocalURL: repositoryLocalURL, scheme: scheme, derivedDataURL: derivedDataURL, archive: archive, resultBundle: archiveResultBundle)
                                self?.processManager.sequence(process: makeArchive, userInfo: ["activity" : ActivityType.archive, "archive": archive, "resultBundle": archiveResultBundle], wasSuccesful: ProcessWasSuccesful { userInfo in
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: Windmill.Notifications.didArchiveProject, object: self, userInfo: ["project":project, "archive": archive])
                                    }
                                    
                                    let exportResultBundle = applicationSupportDirectory.exportResultBundle(at: project.name)
                                    let makeExport = Process.makeExport(repositoryLocalURL: repositoryLocalURL, archive: archive, exportDirectoryURL: directory.exportDirectoryURL(), resultBundle: exportResultBundle)
                                    
                                    let export = directory.export(name: scheme)
                                    let appBundle = directory.appBundle(archive: archive, name: buildSettings.product.name ?? export.name)
                                    
                                    self?.processManager.sequence(process: makeExport, userInfo: ["activity" : ActivityType.export, "export": export, "appBundle": appBundle, "resultBundle": exportResultBundle], wasSuccesful: exportWasSuccesful).launch()
                                }).launch()
                            }).launch()
                        })
                    }).launch()
                }).launch()
            }).launch()
        })
    }
    
    /* fileprivate */ func repeatableDeploy(user: String) -> Sequence {

        let repositoryLocalURL = self.projectSourceDirectory.URL
        let buildSettings = self.projectHomeDirectory.buildSettings()
        
        let exportWasSuccesful = ProcessWasSuccesful { [project = self.project, pollDirectoryURL = self.projectHomeDirectory.pollURL(), weak self] userInfo in

            guard let export = userInfo?["export"] as? Export, let appBundle = userInfo?["appBundle"] as? AppBundle else {
                return
            }


            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Windmill.Notifications.didExportProject, object: self, userInfo: ["project":project, "export": export, "appBundle": appBundle])
            }
            
            let deploy = Process.makeDeploy(repositoryLocalURL: repositoryLocalURL, export: export, forUser: user)
            self?.processManager.sequence(process: deploy, userInfo: ["activity" : ActivityType.deploy], wasSuccesful: ProcessWasSuccesful { userInfo in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Windmill.Notifications.didDeployProject, object: self, userInfo: ["project":project, "buildSettings":buildSettings, "export": export])
                }
                
                #if DEBUG
                    let delayInSeconds:Int = 5
                #else
                    let delayInSeconds:Int = 30
                #endif
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Windmill.Notifications.willMonitorProject, object: self, userInfo: ["project":project])
                }

                if let log = self?.log {
                    os_log("will start monitoring", log: log, type: .debug)
                }

                self?.processManager.repeat(process: Process.makePoll(repositoryLocalURL: repositoryLocalURL, pollDirectoryURL: pollDirectoryURL), every: .seconds(delayInSeconds), until: 1, then: DispatchWorkItem {
                    self?.notificationCenter.post(name: Windmill.Notifications.willStartProject, object: self, userInfo: ["project":project])
                    self?.repeatableDeploy(user: user).launch()
                })
            }).launch()
        }
        
        return self.exportSequence(exportWasSuccesful: exportWasSuccesful)
    }
    
    /* fileprivate */ func repeatableExport() -> Sequence {

        let repositoryLocalURL = self.projectSourceDirectory.URL
        
        let exportWasSuccesful = ProcessWasSuccesful { [project = self.project, pollDirectoryURL = self.projectHomeDirectory.pollURL(), weak self] userInfo in
            
            guard let export = userInfo?["export"] as? Export, let appBundle = userInfo?["appBundle"] as? AppBundle else {
                return
            }

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Windmill.Notifications.didExportProject, object: self, userInfo: ["project":project, "export": export, "appBundle": appBundle])
            }
            
            #if DEBUG
                let delayInSeconds:Int = 5
            #else
                let delayInSeconds:Int = 30
            #endif

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Windmill.Notifications.willMonitorProject, object: self, userInfo: ["project":project])
            }

            if let log = self?.log {
                os_log("will start monitoring", log: log, type: .debug)
            }

            self?.processManager.repeat(process: Process.makePoll(repositoryLocalURL: repositoryLocalURL, pollDirectoryURL: pollDirectoryURL), every: .seconds(delayInSeconds), until: 1, then: DispatchWorkItem {
                self?.notificationCenter.post(name: Windmill.Notifications.willStartProject, object: self, userInfo: ["project":project])
                self?.repeatableExport().launch()
            })
        }
        
        return self.exportSequence(exportWasSuccesful: exportWasSuccesful)
    }
    
    /* fileprivate */ func build(scheme: String, destination: Devices.Destination, repositoryLocalURL: URL, derivedDataURL: URL, resultBundle: ResultBundle, wasSuccesful: ProcessWasSuccesful) {
        
        let buildForTesting = Process.makeBuildForTesting(repositoryLocalURL: repositoryLocalURL, scheme: scheme, destination: destination, derivedDataURL: derivedDataURL, resultBundle: resultBundle)
        
        self.processManager.sequence(process: buildForTesting, userInfo: ["activity" : ActivityType.build, "resultBundle": resultBundle], wasSuccesful: wasSuccesful).launch(recover: RecoverableProcess.recover(terminationStatus: 66) { [applicationSupportDirectory = self.applicationSupportDirectory, project = self.project, weak self] process in
            
            let resultBundle = applicationSupportDirectory.buildResultBundle(at: project.name)
            let build = Process.makeBuild(repositoryLocalURL: repositoryLocalURL, scheme: scheme, destination: destination, derivedDataURL: derivedDataURL, resultBundle: resultBundle)
            self?.processManager.sequence(process: build, userInfo: ["activity" : ActivityType.build, "resultBundle": resultBundle,  WindmillStringKey.test: WindmillStringKey.Test.nothing], wasSuccesful: wasSuccesful).launch()
        })
    }
    
    func removeDerivedData() -> Bool {
        return self.applicationCachesDirectory.removeDerivedData(at: project.name)
    }
    
    // MARK: public
    
    func run(sequence: Sequence)
    {
        self.notificationCenter.post(name: Windmill.Notifications.willStartProject, object: self, userInfo: ["project":project])
        
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
    
    func didExit(manager: ProcessManager, process: Process, isSuccess: Bool, canRecover: Bool, userInfo: [AnyHashable : Any]?) {
        
        guard !canRecover else {
            os_log("will attempt to recover process '%{public}@'", log: log, type: .debug, process.executableURL?.lastPathComponent ?? "")
            return
        }
        
        guard let activity = userInfo?["activity"] as? ActivityType else {
            return
        }

        guard !isSuccess else {
            os_log("activity did exit success `%{public}@`", log: log, type: .debug, activity.rawValue)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notifications.activityDidExitSuccesfully, object: self, userInfo: userInfo)
            }
            return
        }
        
        let error: NSError = NSError.errorTermination(process: process, for: activity, status: process.terminationStatus)
        
        os_log("activity '%{public}@' did error: %{public}@", log: log, type: .error, error)
        
        switch activity {
        case .build, .test, .archive, .export:
            
            guard let resultBundle = userInfo?["resultBundle"] as? ResultBundle, resultBundle.info.errorCount != 0 else {
                NotificationCenter.default.post(name: Notifications.activityError, object: self, userInfo: ["error": error, "activity": activity])
                return
            }
            
            DispatchQueue.main.async { [info = resultBundle.info] in
                
                let error = NSError.activityError(underlyingError: error, for: activity, status: process.terminationStatus, info: info)
                
                NotificationCenter.default.post(name: Notifications.activityError, object: self, userInfo: ["error": error, "activity": activity, "errorCount":info.errorCount, "errorSummaries": info.errorSummaries])
            }
            
        default:
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notifications.activityError, object: self, userInfo: ["error": error, "activity": activity])
            }
        }
        return
    }
}
