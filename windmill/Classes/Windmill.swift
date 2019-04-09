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

extension AppBundle {
    static func make(configuration: Windmill.Configuration, archive: Archive, distributionSummary: Export.DistributionSummary) -> AppBundle {
        return configuration.projectDirectory.appBundle(archive: archive, name: distributionSummary.name)
    }
}

extension Archive {
    
    static func make(configuration: Windmill.Configuration) -> Archive {
        let scheme = configuration.projectDirectory.configuration().detectScheme(name: configuration.project.scheme)
        return configuration.projectDirectory.archive(name: scheme)
    }
}

extension Export {
    
    static func make(configuration: Windmill.Configuration) -> Export {
        let scheme = configuration.projectDirectory.configuration().detectScheme(name: configuration.project.scheme)
        return configuration.projectDirectory.export(name: scheme)
    }
}
/**
 
 A Windmill instance shouldn't be reused.
 When an error occurs, the instance of Windmill must be discarded.
 
 In case on an error, Windmill will post a `Notifications.didError` notification with userInfo: ["error": error, "activity": activity])
 
 - SeeAlso: Windmill.Notifications
 - SeeAlso: ActivityType
 - SeeAlso: NSError+WindmillError
 */
class Windmill: ActivityManagerDelegate
/* final */
{
    class func make(project: Project, subscriptionManager: SubscriptionManager = SubscriptionManager(), processManager: ProcessManager = ProcessManager()) -> Windmill {

        let configuration = Windmill.Configuration.make(project: project)
        let windmill = Windmill(configuration: configuration, subscriptionManager: subscriptionManager)
        
        let activityManager = ActivityManager(subscriptionManager: subscriptionManager, processManager: processManager)
        windmill.activityManager = activityManager
        
        return windmill
    }
    
    public class Configuration {

        class func make(project: Project) -> Configuration {
            return Configuration(project: project)
        }
        
        let project: Project
        let applicationCachesDirectory: ApplicationCachesDirectory
        let applicationSupportDirectory: ApplicationSupportDirectory
        let windmillDirectory: WindmillDirectory
        
        init(project: Project, windmillDirectory: WindmillDirectory = FileManager.default.windmillDirectory, applicationCachesDirectory: ApplicationCachesDirectory = Directory.Windmill.ApplicationCachesDirectory(), applicationSupportDirectory: ApplicationSupportDirectory = Directory.Windmill.ApplicationSupportDirectory()) {
            self.project = project
            self.windmillDirectory = windmillDirectory
            self.applicationCachesDirectory = applicationCachesDirectory
            self.applicationSupportDirectory = applicationSupportDirectory
        }
        
        lazy var projectDirectory = self.windmillDirectory.directory(for: project)
        lazy var projectLogURL = self.projectDirectory.log(name: "raw")
        lazy var projectRepositoryDirectory = self.applicationCachesDirectory.respositoryDirectory(at: project.name)
        
        lazy var derivedData = self.applicationCachesDirectory.derivedData(at: project.name)
    }
    
    struct Notifications {
        static let willStartProject = Notification.Name("will.start")
        static let didCheckoutProject = Notification.Name("io.windmill.windmill.activity.did.checkout")
        static let didBuildProject = Notification.Name("io.windmill.windmill.activity.did.build")
        static let didTestProject = Notification.Name("io.windmill.windmill.activity.did.test")
        static let didArchiveProject = Notification.Name("io.windmill.windmill.activity.did.archive")
        static let didExportProject = Notification.Name("io.windmill.windmill.activity.did.export")
        static let didDistributeProject = Notification.Name("io.windmill.windmill.activity.did.distribute")
        static let isMonitoring = Notification.Name("io.windmill.windmill.activity.monitoring")
        static let SourceCodeChanged = Notification.Name("io.windmill.windmill.subscription.commit")
        
        static let DevicesListed = Notification.Name("io.windmill.windmill.activity.devices.listed")
        

        static let didError = Notification.Name("io.windmill.windmill.activity.did.error")
        
        static let activityDidLaunch = Notification.Name("io.windmill.windmill.activity.did.launch")
        static let activityDidExitSuccesfully = Notification.Name("io.windmill.windmill.activity.did.exit.succesfully")
        
    }
    
    let log = OSLog(subsystem: "io.windmill.windmill", category: "windmill")
    
    let queue = DispatchQueue(label: "io.windmill.windmill")
    
    let configuration: Configuration
    let subscriptionManager: SubscriptionManager
    var activityManager: ActivityManager? {
        didSet {
            activityManager?.windmill = self
            activityManager?.delegate = self
        }
    }

    let activitiesGroup = DispatchGroup()
    var subscriptionStatus: SubscriptionStatus? {
        didSet {
            if oldValue == nil, case .active(let account, let authorizationToken)? = subscriptionStatus {
                self.distribute(account: account, authorizationToken: authorizationToken)
            }
        }
    }

    let standardOutFormattedWriter: StandardOutFormattedWriter
    
    var dispatchSourceWrite: DispatchSourceWrite? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    deinit {
        dispatchSourceWrite?.cancel()
    }

    // MARK: init
    init(configuration: Configuration, subscriptionManager: SubscriptionManager) {

        self.configuration = configuration
        self.standardOutFormattedWriter = StandardOutFormattedWriter.make(queue: self.queue, fileURL: configuration.projectLogURL)
        self.subscriptionManager = subscriptionManager
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(devicesListed(_:)), name: Windmill.Notifications.DevicesListed, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(didExportSuccesfully(_:)), name: Windmill.Notifications.didExportProject, object: self)
    }
    
    @objc func subscriptionActive(notification: NSNotification) {
        self.subscriptionStatus(SubscriptionStatus.default)
    }

    func subscriptionStatus(_ subscriptionStatus: SubscriptionStatus) {
        guard subscriptionStatus.isActive else {
            return
        }
        
        self.subscriptionStatus = subscriptionStatus
    }

    @objc func devicesListed(_ notification: Notification) {
        if let destination = notification.userInfo?["destination"] as? Devices.Destination {
            Process.makeBoot(destination: destination).launch()
        }
    }
    
    // MARK: public
    func removeDerivedData() -> Bool {
        return self.configuration.derivedData.remove()
    }
    
    func isRepositoryDirectoryPresent() -> Bool {
        return self.configuration.projectRepositoryDirectory.exists()
    }
    
    func removeRepositoryDirectory() -> Bool {
        return self.configuration.projectRepositoryDirectory.remove()
    }
    
    @objc func didExportSuccesfully(_ aNotification: Notification) {
        activitiesGroup.leave()
    }
    
    func will(_ manager: ActivityManager, launch activity: ActivityType, userInfo: [AnyHashable : Any]? = nil) {
        
        if activity == .distribute {
            activitiesGroup.wait()
        }
    }
    
    func did(_ manager: ActivityManager, launch activity: ActivityType, userInfo: [AnyHashable : Any]? = nil) {
        self.activitiesGroup.enter()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Windmill.Notifications.activityDidLaunch, object: self, userInfo: userInfo)
        }
    }
    
    func did(_ manager: ActivityManager, exitSuccesfully activity: ActivityType, userInfo: [AnyHashable : Any]? = nil) {
        self.activitiesGroup.leave()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Windmill.Notifications.activityDidExitSuccesfully, object: self, userInfo: userInfo)
        }
    }
    
    func did(_ manager: ActivityManager, terminate activity: ActivityType, error: Error, userInfo: [AnyHashable : Any]?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Windmill.Notifications.didError, object: self, userInfo: userInfo)
        }
    }
    
    func notify(notification name: Notification.Name, userInfo: [AnyHashable : Any]? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: self, userInfo: userInfo)
        }
    }
    
    func distribute(account: Account, authorizationToken: SubscriptionAuthorizationToken) {
        
        guard let activityManager = self.activityManager else {
            preconditionFailure("ActivityManager hasn't been set on Windmill. Did you call the setter?")
        }

        let activityBuiler = activityManager.builder(configuration: self.configuration)
        let activityDistribute = activityBuiler.distributeActivity(account: account, authorizationToken: authorizationToken, activityManager: activityManager, standardOutFormattedWriter: self.standardOutFormattedWriter, queue: self.queue)

        let archive = Archive.make(configuration: self.configuration)
        let export = Export.make(configuration: self.configuration)
        let appBundle = AppBundle.make(configuration: self.configuration, archive: archive, distributionSummary: export.distributionSummary)
        
        activityDistribute(ActivityDistribute.make(export: export, appBundle: appBundle))
    }
    
    func exportAndMonitor(activityManager: ActivityManager, skipCheckout: Bool = false) -> Activity {
        
        let activityBuiler = activityManager.builder(configuration: self.configuration)
        
        let activityPoll =
            activityBuiler.pollActivity(activityManager: activityManager, then: DispatchWorkItem { [weak self] in
                self?.notify(notification: Windmill.Notifications.SourceCodeChanged)
            })
        
        return activityBuiler.exportActivity(activityManager: activityManager, skipCheckout: skipCheckout, next: activityPoll)
    }

    /**
     Do not call this method repeatedly.
     
    */
    public func run(skipCheckout: Bool = false) {
        
        guard let activityManager = self.activityManager else {
            preconditionFailure("ActivityManager hasn't been set on Windmill. Did you call the setter?")
        }
        self.activitiesGroup.enter()
        self.subscriptionStatus(SubscriptionStatus.default)
        
        self.notify(notification: Windmill.Notifications.willStartProject, userInfo: ["project":self.configuration.project])

        let exportAndMonitor = self.exportAndMonitor(activityManager: activityManager, skipCheckout: skipCheckout)
        exportAndMonitor([:])
    }
    
    public func refreshSubscription(failure: @escaping (_ error: Error) -> Void) {
        self.subscriptionManager.refreshSubscription  { token, error in
            
            switch(token, error) {
            case(_, let error as SubscriptionError):
                os_log("The subscription authorization token failed to refresh '%{public}@'.", log: .default, type: .error, error.localizedDescription)
                self.standardOutFormattedWriter.error(error: error)
                self.dispatchSourceWrite = self.standardOutFormattedWriter.activate()
                failure(error)
            case(_, let error?):
                os_log("The subscription authorization token failed to refresh '%{public}@'.", log: .default, type: .error, error.localizedDescription)
                self.standardOutFormattedWriter.failed(title: "Subscription Access", error: (error as NSError))
                self.dispatchSourceWrite = self.standardOutFormattedWriter.activate()
                failure(error)
            case(_, _):
                os_log("Success: subscription authorization token refreshed.", log: .default, type: .debug)
            }
        }
    }
}
