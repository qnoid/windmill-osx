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
    
    class func make(project: Project, user: String? = try? Keychain.defaultKeychain().findWindmillUser(), skipCheckout: Bool = false) -> (windmill: Windmill, chain: ProcessChain) {

        let windmill = Windmill(project: project)

        guard let user = user else {
            let repeatableExport = windmill.repeatableExport(skipCheckout: skipCheckout)
            return (windmill: windmill, chain: repeatableExport)
        }

        let repeatableDeploy = windmill.repeatableDeploy(user: user, skipCheckout: skipCheckout)
        return (windmill: windmill, chain: repeatableDeploy)
    }
    
    struct Notifications {
        static let willStartProject = Notification.Name("will.start")
        static let didCheckoutProject = Notification.Name("did.checkout")
        static let didBuildProject = Notification.Name("did.build")
        static let didTestProject = Notification.Name("did.test")
        static let didArchiveProject = Notification.Name("did.archive")
        static let didExportProject = Notification.Name("did.export")
        static let didDeployProject = Notification.Name("did.deploy")
        static let willMonitorProject = Notification.Name("will.monitor")
        
        static let didError = Notification.Name("did.error")
        
        static let activityDidLaunch = Notification.Name("activity.did.launch")
        static let activityDidExitSuccesfully = Notification.Name("activity.did.exit.succesfully")
        
    }
    
    let log = OSLog(subsystem: "io.windmill.windmill", category: "windmill")
    let notificationCenter = NotificationCenter.default
    
    let applicationCachesDirectory = Directory.Windmill.ApplicationCachesDirectory()
    let applicationSupportDirectory = Directory.Windmill.ApplicationSupportDirectory()

    lazy var projectHomeDirectory: ProjectHomeDirectory = FileManager.default.windmillHomeDirectory.projectHomeDirectory(at: project.name)
    lazy var projectLogURL: URL = projectHomeDirectory.log(name: "raw")
    lazy var projectRepositoryDirectory: ProjectRepositoryDirectory = applicationCachesDirectory.projectRepositoryDirectory(at: project.name)

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
    
    private func build(projectLocalURL: Project.LocalURL, project: Project, scheme: String, destination: Devices.Destination, wasSuccesful: ProcessWasSuccesful?) {
        self.build(project: project, scheme: scheme, destination: destination, repositoryLocalURL: projectRepositoryDirectory.URL, projectLocalURL: projectLocalURL, derivedDataURL: applicationCachesDirectory.derivedDataURL(at: project.name), resultBundle: applicationSupportDirectory.buildResultBundle(at: project.name), log: projectLogURL, wasSuccesful: wasSuccesful)
    }
    
    private func didBuild(project: Project, using buildSettings: BuildSettings, appBundle: AppBundle, destination: Devices.Destination) {
        let directory = self.projectHomeDirectory

        let appBundleBuilt = appBundle
        let appBundle = directory.appBundle(name: project.name)
        try? FileManager.default.copyItem(at: appBundleBuilt.url, to: appBundle.url)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Windmill.Notifications.didBuildProject, object: self, userInfo: ["project":project, "appBundle": appBundle, "destination": destination])
        }
        
    }
    
    private func didTest(project: Project, testsCount: Int, devices: Devices, destination: Devices.Destination, testableSummaries: [TestableSummary]) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Windmill.Notifications.didTestProject, object: self, userInfo: ["project":project, "devices": devices, "destination": destination, "testsCount": testsCount, "testableSummaries": testableSummaries])
        }
    }
    
    private func didReadDevices(devices: Devices) {
        guard let destination = devices.destination else {
            os_log("Destination couldn't not be read from devices at '%{public}@'. Is a 'devices.json' present? Does it define a 'destination' dictionary?`", log: log, type: .debug, devices.url.path)
            return
        }
        Process.makeBoot(destination: destination).launch()
    }
    
    private func didCheckout(commit: Repository.Commit) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Windmill.Notifications.didCheckoutProject, object: self, userInfo: ["commit": commit])
        }
    }


    // MARK: private
    
    func buildChain(repositoryLocalURL: Repository.LocalURL? = nil, projectLocalURL: Project.LocalURL? = nil, derivedDataURL: URL, resultBundle: ResultBundle, buildWasSuccesful: ProcessWasSuccesful? = nil) -> ProcessChain {
        let directory = self.projectHomeDirectory
        let log = self.projectLogURL
        let repositoryLocalURL = repositoryLocalURL ?? projectRepositoryDirectory.URL
        let projectLocalURL = projectLocalURL ?? repositoryLocalURL
        let configuration = directory.configuration()

        let readProjectConfiguration = Process.makeList(project: project, configuration: configuration, projectLocalURL: projectLocalURL)
        return self.processManager.processChain(process: readProjectConfiguration, userInfo: ["activity": ActivityType.readProjectConfiguration, "configuration": configuration], wasSuccesful: ProcessWasSuccesful { [project = self.project, buildSettings = directory.buildSettings(), weak self] userInfo in
            
            let scheme = configuration.detectScheme(name: project.scheme)
            let readBuildSettings = Process.makeShowBuildSettings(projectLocalURL: projectLocalURL, project: project, scheme: scheme, buildSettings: buildSettings)
            self?.processManager.processChain(process: readBuildSettings, userInfo: ["activity" : ActivityType.showBuildSettings], wasSuccesful: ProcessWasSuccesful { [devices = directory.devices()] userInfo in
                
                let buildSettings = directory.buildSettings().for(project: project.name)
                let readDevices = Process.makeList(devices: devices, for: buildSettings.deployment)
                self?.processManager.processChain(process: readDevices, userInfo: ["activity" : ActivityType.devices, "devices": devices], wasSuccesful: ProcessWasSuccesful { userInfo in
                    
                    self?.didReadDevices(devices: devices)
                    
                    let appBundle = directory.appBundle(name: project.name)
                    try? FileManager.default.removeItem(at: appBundle.url)
                    
                    guard let destination = devices.destination else {
                        if let log = self?.log {
                            os_log("Destination couldn't not be read from devices at '%{public}@'. Is a 'devices.json' present? Does it define a '' dictionary?`", log: log, type: .debug, devices.url.path)
                        }
                        return
                    }
                    
                    self?.build(project: project, scheme: scheme, destination: destination, repositoryLocalURL: repositoryLocalURL, projectLocalURL: projectLocalURL, derivedDataURL: derivedDataURL, resultBundle: resultBundle, log: log, wasSuccesful: buildWasSuccesful)
                }).launch()
            }).launch()
        })
    }
    
    /* private */ func exportChain(skipCheckout: Bool = false, exportWasSuccesful: ProcessWasSuccesful? = nil) -> ProcessChain {
        
        let directory = self.projectHomeDirectory
        let projectLogURL = self.projectLogURL
        let repositoryLocalURL = projectRepositoryDirectory
        let checkout: Process = skipCheckout ? Process.makeSuccess() : Process.makeCheckout(sourceDirectory: repositoryLocalURL, project: self.project, log: projectLogURL)
        let derivedDataURL = applicationCachesDirectory.derivedDataURL(at: project.name)
        let applicationSupportDirectory = self.applicationSupportDirectory
        
        
        try? FileManager.default.removeItem(at: projectLogURL)
        
        return self.processManager.processChain(process:checkout, userInfo: ["activity" : ActivityType.checkout], wasSuccesful: ProcessWasSuccesful { [project = self.project, configuration = directory.configuration(), applicationCachesDirectory = applicationCachesDirectory, log = self.log, weak self] userInfo in
            
            os_log("Checked out source under: '%{public}@'", log: log, type: .debug, repositoryLocalURL.URL.path)

            let findProject = Process.makeFind(project: project, repositoryLocalURL: repositoryLocalURL.URL)
            
            self?.processManager.processResult(process: findProject).launch { projectDirectory in
                
                let projectLocalURL: Project.LocalURL
                
                if let projectDirectory = projectDirectory.value {
                    projectLocalURL = URL(fileURLWithPath: projectDirectory)
                } else {
                    projectLocalURL = repositoryLocalURL.URL
                }
                
                os_log("Project found under: '%{public}@'", log: log, type: .debug, projectLocalURL.path)

                if let commit = applicationCachesDirectory.commit(baseURL: projectLocalURL, project: project) {
                    self?.didCheckout(commit: commit)
                }
            
                let readProjectConfiguration = Process.makeList(project: project, configuration: configuration, projectLocalURL: projectLocalURL)
                self?.processManager.processChain(process: readProjectConfiguration, userInfo: ["activity": ActivityType.readProjectConfiguration, "configuration": configuration], wasSuccesful: ProcessWasSuccesful { userInfo in
                    
                    let scheme = configuration.detectScheme(name: project.scheme)
                    let readBuildSettings = Process.makeShowBuildSettings(projectLocalURL: projectLocalURL, project: project, scheme: scheme, buildSettings: directory.buildSettings())
                    self?.processManager.processChain(process: readBuildSettings, userInfo: ["activity" : ActivityType.showBuildSettings], wasSuccesful: ProcessWasSuccesful { [devices = directory.devices()] userInfo in
                        
                        let buildSettings = directory.buildSettings().for(project: project.name)
                        
                        let readDevices = Process.makeList(devices: devices, for: buildSettings.deployment)
                        self?.processManager.processChain(process: readDevices, userInfo: ["activity" : ActivityType.devices, "devices": devices], wasSuccesful: ProcessWasSuccesful { userInfo in
                            
                            self?.didReadDevices(devices: devices)

                            let appBundle = directory.appBundle(name: project.name)
                            try? FileManager.default.removeItem(at: appBundle.url)
                            
                            guard let destination = devices.destination else {
                                os_log("Destination couldn't not be read from devices at '%{public}@'. Is a 'devices.json' present? Does it define a '' dictionary?`", log: log, type: .debug, devices.url.path)
                                return
                            }

                            self?.build(projectLocalURL:projectLocalURL, project: project, scheme: scheme, destination: destination, wasSuccesful: ProcessWasSuccesful { [destination = destination, devices = devices] buildInfo in

                                let appBundle = directory.appBundle(derivedDataURL: derivedDataURL, name: buildSettings.product?.name ?? project.name)
                                self?.didBuild(project: project, using: buildSettings, appBundle: appBundle, destination: destination)

                                let test: Process
                                let userInfo: [AnyHashable: Any]
                                let testResultBundle = applicationSupportDirectory.testResultBundle(at: project.name)
                                
                                if WindmillStringKey.Test.nothing == (buildInfo?[WindmillStringKey.test] as? WindmillStringKey.Test) {
                                    userInfo = ["activity" : ActivityType.test, "resultBundle": testResultBundle]
                                    test = Process.makeSuccess()
                                } else {
                                    userInfo = ["activity" : ActivityType.test, "artefact": ArtefactType.testReport, "devices": devices, "destination": destination, "resultBundle": testResultBundle]
                                    test = Process.makeTestWithoutBuilding(projectLocalURL: projectLocalURL, project: project, scheme: scheme, destination: destination, derivedDataURL: derivedDataURL, resultBundle: testResultBundle, log: projectLogURL)
                                }
                                
                                self?.processManager.processChain(process: test, userInfo: userInfo, wasSuccesful: ProcessWasSuccesful { userInfo in

                                    if let testResultBundle = userInfo?["resultBundle"] as? ResultBundle, let testsCount = testResultBundle.info.testsCount, testsCount >= 0 {
                                        self?.didTest(project: project, testsCount: testsCount, devices: devices, destination: destination, testableSummaries: testResultBundle.testSummaries?.testableSummaries ?? [])
                                    }

                                    let archive: Archive = directory.archive(name: scheme)
                                    let archiveResultBundle = applicationSupportDirectory.archiveResultBundle(at: project.name)
                                    let makeArchive = Process.makeArchive(projectLocalURL: projectLocalURL, project: project, scheme: scheme, derivedDataURL: derivedDataURL, archive: archive, resultBundle: archiveResultBundle, log: projectLogURL)
                                    self?.processManager.processChain(process: makeArchive, userInfo: ["activity" : ActivityType.archive, "artefact": ArtefactType.archiveBundle, "archive": archive, "resultBundle": archiveResultBundle], wasSuccesful: ProcessWasSuccesful { userInfo in
                                        DispatchQueue.main.async {
                                            NotificationCenter.default.post(name: Windmill.Notifications.didArchiveProject, object: self, userInfo: ["project":project, "archive": archive])
                                        }
                                        
                                        let exportResultBundle = applicationSupportDirectory.exportResultBundle(at: project.name)
                                        let makeExport = Process.makeExport(projectLocalURL: projectLocalURL, archive: archive, exportDirectoryURL: directory.exportDirectoryURL(), resultBundle: exportResultBundle, log: projectLogURL)
                                        
                                        let export = directory.export(name: scheme)
                                        
                                        self?.processManager.processChain(process: makeExport, userInfo: ["activity" : ActivityType.export, "artefact": ArtefactType.ipaFile, "export": export, "appBundle": appBundle, "resultBundle": exportResultBundle], wasSuccesful: ProcessWasSuccesful { userInfo in
                                            
                                            let appBundle = directory.appBundle(archive: archive, name: export.distributionSummary.name)
                                            
                                            let userInfo = userInfo?.merging(["project":project, "appBundle": appBundle], uniquingKeysWith: { (userInfo, _) -> Any in
                                                return userInfo
                                            })
                                            
                                            DispatchQueue.main.async {
                                                NotificationCenter.default.post(name: Windmill.Notifications.didExportProject, object: self, userInfo: userInfo)
                                            }
                                            
                                            exportWasSuccesful?.perform(userInfo: userInfo)
                                        }).launch()
                                    }).launch()
                                }).launch()
                            })
                        }).launch()
                    }).launch()
                }).launch()
            }
        })
    }
    
    /* fileprivate */ func repeatableDeploy(user: String, skipCheckout: Bool = false) -> ProcessChain {

        let projectLogURL = self.projectLogURL
        let repositoryLocalURL = self.projectRepositoryDirectory.URL
        
        let exportWasSuccesful = ProcessWasSuccesful { [project = self.project, pollDirectoryURL = self.projectHomeDirectory.pollURL(), log = self.log, weak self] userInfo in

            guard let export = userInfo?["export"] as? Export, let appBundle = userInfo?["appBundle"] as? AppBundle else {
                return
            }

            let deploy = Process.makeDeploy(export: export, forUser: user, log: projectLogURL)
            self?.processManager.processChain(process: deploy, userInfo: ["activity" : ActivityType.deploy, "artefact": ArtefactType.otaDistribution], wasSuccesful: ProcessWasSuccesful { userInfo in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Windmill.Notifications.didDeployProject, object: self, userInfo: ["project":project, "export": export, "appBundle":appBundle])
                }
                
                #if DEBUG
                    let delayInSeconds:Int = 5
                #else
                    let delayInSeconds:Int = 30
                #endif
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Windmill.Notifications.willMonitorProject, object: self, userInfo: ["project":project])
                }

                os_log("will start monitoring", log: log, type: .debug)

                self?.processManager.repeat(process: Process.makePoll(repositoryLocalURL: repositoryLocalURL, pollDirectoryURL: pollDirectoryURL), every: .seconds(delayInSeconds), until: 1, then: DispatchWorkItem {
                    self?.notificationCenter.post(name: Windmill.Notifications.willStartProject, object: self, userInfo: ["project":project])
                    self?.repeatableDeploy(user: user).launch()
                })
            }).launch()
        }
        
        return self.exportChain(skipCheckout: skipCheckout, exportWasSuccesful: exportWasSuccesful)
    }
    
    /* fileprivate */ func repeatableExport(skipCheckout: Bool = false) -> ProcessChain {

        let repositoryLocalURL = self.projectRepositoryDirectory.URL
        
        let exportWasSuccesful = ProcessWasSuccesful { [project = self.project, pollDirectoryURL = self.projectHomeDirectory.pollURL(), weak self] userInfo in
            
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
        
        return self.exportChain(skipCheckout: skipCheckout, exportWasSuccesful: exportWasSuccesful)
    }
    
    /* fileprivate */ func build(project: Project, scheme: String, destination: Devices.Destination, repositoryLocalURL: Repository.LocalURL, projectLocalURL: Project.LocalURL, derivedDataURL: URL, resultBundle: ResultBundle, log: URL, wasSuccesful: ProcessWasSuccesful?) {
        
        let buildForTesting = Process.makeBuildForTesting(projectLocalURL: projectLocalURL, project:project, scheme: scheme, destination: destination, derivedDataURL: derivedDataURL, resultBundle: resultBundle, log: log)
        
        self.processManager.processChain(process: buildForTesting, userInfo: ["activity" : ActivityType.build, "resultBundle": resultBundle, "artefact": ArtefactType.appBundle], wasSuccesful: wasSuccesful).launch(recover: RecoverableProcess.recover(terminationStatus: 66) { [applicationSupportDirectory = self.applicationSupportDirectory, project = self.project, weak self] process in
            
            let resultBundle = applicationSupportDirectory.buildResultBundle(at: project.name)
            let build = Process.makeBuild(projectLocalURL: projectLocalURL, project:project, scheme: scheme, destination: destination, derivedDataURL: derivedDataURL, resultBundle: resultBundle, log: log)
            self?.processManager.processChain(process: build, userInfo: ["activity" : ActivityType.build, "resultBundle": resultBundle, "artefact": ArtefactType.appBundle, WindmillStringKey.test: WindmillStringKey.Test.nothing], wasSuccesful: wasSuccesful).launch()
        })
    }
    
    func removeDerivedData() -> Bool {
        return self.applicationCachesDirectory.removeDerivedData(at: project.name)
    }
    
    // MARK: public
    
    func run(process chain: ProcessChain)
    {
        self.notificationCenter.post(name: Windmill.Notifications.willStartProject, object: self, userInfo: ["project":project])
        
        chain.launch()
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
        
        guard let resultBundle = userInfo?["resultBundle"] as? ResultBundle, FileManager.default.fileExists(atPath: resultBundle.url.path) else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notifications.didError, object: self, userInfo: userInfo?.merging(["error": error, "activity": activity], uniquingKeysWith:  { (userInfo, _) -> Any in
                    return userInfo
                }))
            }
            return
        }
        
        let info = resultBundle.info
        
        if info.errorCount == 0, info.testsFailedCount == 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notifications.didError, object: self, userInfo: userInfo?.merging(["error": error, "activity": activity], uniquingKeysWith:  { (userInfo, _) -> Any in
                    return userInfo
                }))
            }
            return
        }
        
        if info.errorCount > 0 {
            DispatchQueue.main.async { [errorCount = info.errorCount] in
                
                let error = NSError.activityError(underlyingError: error, for: activity, status: process.terminationStatus, info: info)
                
                NotificationCenter.default.post(name: Notifications.didError, object: self, userInfo: userInfo?.merging(["error": error, "activity": activity, "errorCount":errorCount, "errorSummaries": info.errorSummaries], uniquingKeysWith: { (userInfo, _) -> Any in
                    return userInfo
                }))
            }
        }
        
        if let testsFailedCount = info.testsFailedCount, testsFailedCount > 0 {
            DispatchQueue.main.async { [testableSummaries = resultBundle.testSummaries?.testableSummaries] in
                let error = NSError.testError(underlyingError: error, status: process.terminationStatus, info: info)
                
                NotificationCenter.default.post(name: Notifications.didError, object: self, userInfo: userInfo?.merging(["error": error, "activity": activity, "testsFailedCount":testsFailedCount, "testFailureSummaries": info.testFailureSummaries, "testableSummaries": testableSummaries ?? []], uniquingKeysWith: { (userInfo, _) -> Any in
                    return userInfo
                }))
            }
        }
    }
}
